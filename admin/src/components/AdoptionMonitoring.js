import React, { useState, useEffect, useCallback } from 'react';
import { supabase } from '../config/supabaseClient';
import {
  FiRefreshCw, FiEye, FiCheckCircle, FiXCircle,
  FiX, FiClock, FiFileText, FiUser, FiHome, FiCheck,
  FiPhone, FiMail, FiMapPin,
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import './AdoptionMonitoring.css';

function AdoptionMonitoring() {
  const [applications, setApplications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedApp, setSelectedApp] = useState(null);
  const [reviewNotes, setReviewNotes] = useState('');
  const [updating, setUpdating] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3500);
  };

  const fetchApplications = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data, error: fetchError } = await supabase
        .from('adoption_applications')
        .select(`
          id,
          pet_id,
          applicant_id,
          full_name,
          contact_number,
          address,
          occupation,
          housing_type,
          has_other_pets,
          other_pets_details,
          reason_for_adoption,
          status,
          reviewed_by,
          review_notes,
          decided_at,
          created_at,
          updated_at,
          pet:pet_id (
            id,
            name,
            type,
            breed,
            image_url,
            shelter:shelter_id (
              id,
              name
            )
          ),
          applicant:applicant_id (
            id,
            full_name
          )
        `)
        .order('created_at', { ascending: false });

      if (fetchError) throw fetchError;
      setApplications(data || []);
    } catch (err) {
      setError('Failed to fetch adoption applications: ' + err.message);
      console.error(err);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchApplications();

    const channel = supabase
      .channel('admin_applications_realtime')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'adoption_applications',
        },
        () => {
          fetchApplications();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [fetchApplications]);

  const updateApplicationStatus = async (appId, newStatus, notes = null) => {
    setUpdating(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();

      const updateData = {
        status: newStatus,
        updated_at: new Date().toISOString(),
      };

      if (newStatus === 'approved' || newStatus === 'rejected') {
        updateData.decided_at = new Date().toISOString();
      }
      if (user) {
        updateData.reviewed_by = user.id;
      }
      if (notes !== null) {
        updateData.review_notes = notes;
      }

      const { error: updateError } = await supabase
        .from('adoption_applications')
        .update(updateData)
        .eq('id', appId);

      if (updateError) throw updateError;

      // Pet status follows the decision in the database (trigger
      // link_pet_status_to_application): approved -> pending, and back to
      // available only when an approved application is rejected. Staff mark
      // the pet adopted in Pet records once it goes home.

      if (selectedApp && selectedApp.id === appId) {
        setSelectedApp((prev) => prev ? {
          ...prev,
          status: newStatus,
          review_notes: notes !== null ? notes : prev.review_notes,
          decided_at: updateData.decided_at || prev.decided_at,
        } : null);
      }

      showToast(`Application marked as ${newStatus.replace('_', ' ').toUpperCase()}`);
      fetchApplications();
    } catch (err) {
      showToast('Failed to update application: ' + err.message);
      console.error(err);
    }
    setUpdating(false);
  };

  const openDetailsModal = (app) => {
    setSelectedApp(app);
    setReviewNotes(app.review_notes || '');
  };

  const closeDetailsModal = () => {
    setSelectedApp(null);
    setReviewNotes('');
  };

  const filteredApplications = statusFilter === 'all'
    ? applications
    : applications.filter((a) => a.status === statusFilter);

  // Counts
  const counts = {
    all: applications.length,
    pending: applications.filter((a) => a.status === 'pending').length,
    under_review: applications.filter((a) => a.status === 'under_review').length,
    approved: applications.filter((a) => a.status === 'approved').length,
    rejected: applications.filter((a) => a.status === 'rejected').length,
  };

  if (loading) {
    return <div className="loading">Loading adoption applications...</div>;
  }

  return (
    <div className="adoption-monitoring">
      <p className="section-subtitle">
        Review, screen, and track pet adoption requests and applicant qualifications.
      </p>

      {toastMessage && (
        <div className="adoption-toast">
          <FiCheck className="toast-icon" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Filter Chips Bar */}
      <div className="adoption-filter-row">
        <div className="filter-chips-wrap">
          <button
            className={`adoption-chip ${statusFilter === 'all' ? 'active' : ''}`}
            onClick={() => setStatusFilter('all')}
          >
            All Applications <span className="chip-badge">{counts.all}</span>
          </button>
          <button
            className={`adoption-chip chip-pending ${statusFilter === 'pending' ? 'active' : ''}`}
            onClick={() => setStatusFilter('pending')}
          >
            <FiClock /> Pending <span className="chip-badge">{counts.pending}</span>
          </button>
          <button
            className={`adoption-chip chip-review ${statusFilter === 'under_review' ? 'active' : ''}`}
            onClick={() => setStatusFilter('under_review')}
          >
            <FiFileText /> Under Review <span className="chip-badge">{counts.under_review}</span>
          </button>
          <button
            className={`adoption-chip chip-approved ${statusFilter === 'approved' ? 'active' : ''}`}
            onClick={() => setStatusFilter('approved')}
          >
            <FiCheckCircle /> Approved <span className="chip-badge">{counts.approved}</span>
          </button>
          <button
            className={`adoption-chip chip-rejected ${statusFilter === 'rejected' ? 'active' : ''}`}
            onClick={() => setStatusFilter('rejected')}
          >
            <FiXCircle /> Rejected <span className="chip-badge">{counts.rejected}</span>
          </button>
        </div>

        <button onClick={fetchApplications} className="refresh-adoptions-btn" title="Refresh Applications">
          <FiRefreshCw />
        </button>
      </div>

      {error && <div className="error-message">{error}</div>}

      {/* Table of Applications */}
      <div className="adoptions-table-container">
        <table className="adoptions-table">
          <thead>
            <tr>
              <th>Pet Target</th>
              <th>Applicant Information</th>
              <th>Partner Shelter</th>
              <th>Housing Type</th>
              <th>Submission Date</th>
              <th>Current Status</th>
              <th className="th-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredApplications.length > 0 ? (
              filteredApplications.map((app) => (
                <tr key={app.id}>
                  <td>
                    <div className="pet-info-cell">
                      <div className="pet-thumb-icon">
                        <MdPets />
                      </div>
                      <div className="pet-text-meta">
                        <strong>{app.pet?.name || 'Pet ID #' + (app.pet_id ? app.pet_id.slice(0, 6) : 'N/A')}</strong>
                        <span className="pet-breed-tag">
                          {app.pet?.type ? `${app.pet.type.toUpperCase()} • ${app.pet.breed || 'Mixed'}` : 'Rescue Pet'}
                        </span>
                      </div>
                    </div>
                  </td>
                  <td>
                    <div className="applicant-info-cell">
                      <strong>{app.full_name || app.applicant?.full_name || 'Anonymous Applicant'}</strong>
                      <span className="applicant-contact-sub">{app.applicant?.email || app.contact_number || 'No contact provided'}</span>
                    </div>
                  </td>
                  <td>
                    <span className="shelter-link-badge">
                      <FiHome /> {app.pet?.shelter?.name || 'JALRG Shelter'}
                    </span>
                  </td>
                  <td>
                    <span className="housing-pill">
                      {app.housing_type ? app.housing_type.toUpperCase() : 'OWNED'}
                    </span>
                  </td>
                  <td>
                    <span className="date-cell">
                      {new Date(app.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}
                    </span>
                  </td>
                  <td>
                    <span className={`status-pill status-${app.status}`}>
                      {app.status ? app.status.replace('_', ' ').toUpperCase() : 'PENDING'}
                    </span>
                  </td>
                  <td className="actions">
                    <button
                      onClick={() => openDetailsModal(app)}
                      className="review-app-btn"
                      title="Open Full Screening Dossier"
                    >
                      <FiEye /> Review Dossier
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="7" className="empty-adoptions-cell">
                  <div className="empty-adoptions-content">
                    <FiFileText className="empty-icon" />
                    <h4>No Applications in this Category</h4>
                    <p>New adoption applications submitted via the My Future Pet mobile app will automatically appear here.</p>
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Review Dossier Modal */}
      {selectedApp && (
        <div className="adoption-modal-backdrop" onClick={closeDetailsModal}>
          <div className="adoption-dossier-card" onClick={(e) => e.stopPropagation()}>
            <div className="dossier-header">
              <div className="dossier-title-wrap">
                <div className="dossier-header-icon">
                  <MdPets />
                </div>
                <div>
                  <h3>Adoption Screening Dossier</h3>
                  <span className="dossier-id-sub">Application #{selectedApp.id.slice(0, 8).toUpperCase()}</span>
                </div>
              </div>
              <button className="modal-close-btn" onClick={closeDetailsModal}>
                <FiX />
              </button>
            </div>

            <div className="dossier-body">
              {/* Pet Card Banner */}
              <div className="dossier-pet-banner">
                <div className="pet-banner-icon">
                  <MdPets />
                </div>
                <div className="pet-banner-info">
                  <h4>Target Pet: {selectedApp.pet?.name || 'Shelter Pet'}</h4>
                  <span>
                    {selectedApp.pet?.type?.toUpperCase()} • Breed: {selectedApp.pet?.breed || 'Domestic'} • Shelter: {selectedApp.pet?.shelter?.name || 'JALRG'}
                  </span>
                </div>
                <div className="pet-banner-status">
                  <span className={`status-pill status-${selectedApp.status}`}>
                    {selectedApp.status.replace('_', ' ').toUpperCase()}
                  </span>
                </div>
              </div>

              {/* Dossier Grid Details */}
              <div className="dossier-grid">
                <div className="dossier-section">
                  <h5>Applicant Information</h5>
                  <div className="info-kv-list">
                    <div className="info-kv-row">
                      <span className="kv-label"><FiUser /> Full Name:</span>
                      <strong className="kv-val">{selectedApp.full_name || selectedApp.applicant?.full_name || 'N/A'}</strong>
                    </div>
                    <div className="info-kv-row">
                      <span className="kv-label"><FiMail /> Email:</span>
                      <span className="kv-val">{selectedApp.applicant?.email || 'N/A'}</span>
                    </div>
                    <div className="info-kv-row">
                      <span className="kv-label"><FiPhone /> Phone:</span>
                      <span className="kv-val">{selectedApp.contact_number || 'N/A'}</span>
                    </div>
                    <div className="info-kv-row">
                      <span className="kv-label"><FiMapPin /> Address:</span>
                      <span className="kv-val">{selectedApp.address || 'Bohol, Philippines'}</span>
                    </div>
                    <div className="info-kv-row">
                      <span className="kv-label">Occupation:</span>
                      <span className="kv-val">{selectedApp.occupation || 'Employed'}</span>
                    </div>
                  </div>
                </div>

                <div className="dossier-section">
                  <h5>Living Environment &amp; Experience</h5>
                  <div className="info-kv-list">
                    <div className="info-kv-row">
                      <span className="kv-label"><FiHome /> Housing Type:</span>
                      <strong className="kv-val">{selectedApp.housing_type ? selectedApp.housing_type.toUpperCase() : 'OWNED HOUSE'}</strong>
                    </div>
                    <div className="info-kv-row">
                      <span className="kv-label">Has Other Pets:</span>
                      <span className={`kv-val ${selectedApp.has_other_pets ? 'has-pets-yes' : 'has-pets-no'}`}>
                        {selectedApp.has_other_pets ? 'Yes, has companion pets' : 'No prior pets'}
                      </span>
                    </div>
                    {selectedApp.has_other_pets && selectedApp.other_pets_details && (
                      <div className="info-kv-row">
                        <span className="kv-label">Other Pets Details:</span>
                        <span className="kv-val">{selectedApp.other_pets_details}</span>
                      </div>
                    )}
                    <div className="info-kv-row">
                      <span className="kv-label">Submitted On:</span>
                      <span className="kv-val">{new Date(selectedApp.created_at).toLocaleString()}</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Reason for Adoption */}
              <div className="dossier-reason-box">
                <h5>Reason for Adoption &amp; Commitment Statement</h5>
                <p>
                  &quot;{selectedApp.reason_for_adoption || 'Committed to providing a loving, safe, and permanent forever home for this rescue animal.'}&quot;
                </p>
              </div>

              {/* Review Notes Section */}
              <div className="dossier-notes-box">
                <h5>Administrator &amp; Shelter Staff Review Notes</h5>
                <textarea
                  rows="3"
                  placeholder="Record assessment notes, phone interview impressions, or required follow-up verification..."
                  value={reviewNotes}
                  onChange={(e) => setReviewNotes(e.target.value)}
                />
              </div>

              {/* Decision Action Buttons */}
              <div className="dossier-actions-bar">
                <div className="decision-buttons">
                  <button
                    className="decision-btn btn-approve"
                    onClick={() => updateApplicationStatus(selectedApp.id, 'approved', reviewNotes)}
                    disabled={updating}
                  >
                    <FiCheckCircle /> Approve Adoption
                  </button>
                  <button
                    className="decision-btn btn-review"
                    onClick={() => updateApplicationStatus(selectedApp.id, 'under_review', reviewNotes)}
                    disabled={updating}
                  >
                    <FiClock /> Mark Under Review
                  </button>
                  <button
                    className="decision-btn btn-reject"
                    onClick={() => updateApplicationStatus(selectedApp.id, 'rejected', reviewNotes)}
                    disabled={updating}
                  >
                    <FiXCircle /> Reject Application
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default AdoptionMonitoring;
