import React, { useState, useEffect, useCallback } from 'react';
import { supabase } from '../config/supabaseClient';
import {
  FiCalendar, FiRefreshCw, FiCheckCircle, FiXCircle,
  FiClock, FiUser, FiPhone, FiMail, FiMapPin,
  FiSearch, FiFilter, FiCheck, FiX,
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import './AppointmentManagement.css';

function AppointmentManagement() {
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [statusFilter, setStatusFilter] = useState('all'); // 'all' | 'pending' | 'confirmed' | 'completed' | 'cancelled'
  const [searchTerm, setSearchTerm] = useState('');

  // Action / Detail modals
  const [selectedAppt, setSelectedAppt] = useState(null);
  const [actionModal, setActionModal] = useState(null); // { type: 'confirm'|'complete'|'cancel', appt }
  const [actionNotes, setActionNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [toastMessage, setToastMessage] = useState('');

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3800);
  };

  const fetchAppointments = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const { data, error: fetchErr } = await supabase
        .from('appointments')
        .select(`
          id,
          appointment_type,
          scheduled_at,
          status,
          notes,
          created_at,
          updated_at,
          applicant:user_id (
            id,
            full_name
          ),
          pet:pet_id (
            id,
            name,
            type,
            breed,
            image_url
          ),
          shelter:shelter_id (
            id,
            name,
            address,
            contact_number
          )
        `)
        .order('scheduled_at', { ascending: true });

      if (fetchErr) throw fetchErr;
      setAppointments(data || []);
    } catch (err) {
      setError('Failed to fetch appointment schedules: ' + err.message);
      console.error(err);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchAppointments();

    const channel = supabase
      .channel('admin_appointments_realtime')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'appointments',
        },
        () => {
          fetchAppointments();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [fetchAppointments]);

  const handleUpdateStatus = async (newStatus, notes = null) => {
    if (!actionModal) return;
    setSubmitting(true);
    try {
      const updatePayload = {
        status: newStatus,
        updated_at: new Date().toISOString(),
      };
      if (notes !== null && notes !== undefined) {
        updatePayload.notes = notes.trim();
      }

      const { error: updateErr } = await supabase
        .from('appointments')
        .update(updatePayload)
        .eq('id', actionModal.appt.id);

      if (updateErr) throw updateErr;

      // Dispatch notification to user
      const userId = actionModal.appt.applicant?.id;
      const petName = actionModal.appt.pet?.name || 'the shelter';
      if (userId) {
        try {
          let notifTitle = 'Appointment Update';
          let notifMsg = `Your appointment for ${petName} is now ${newStatus}.`;
          if (newStatus === 'confirmed') {
            notifTitle = 'Appointment Confirmed! 📅';
            notifMsg = `Your appointment for ${petName} has been confirmed! We look forward to seeing you.`;
          } else if (newStatus === 'cancelled') {
            notifTitle = 'Appointment Cancelled';
            notifMsg = `Your appointment for ${petName} was cancelled. ${notes ? 'Reason: ' + notes : ''}`;
          } else if (newStatus === 'completed') {
            notifTitle = 'Appointment Completed 🐾';
            notifMsg = `Thank you for visiting! Your appointment for ${petName} is marked as completed.`;
          }
          await supabase.from('notifications').insert({
            user_id: userId,
            title: notifTitle,
            body: notifMsg,
            type: 'appointment_status',
            read_at: null,
          });
        } catch (e) {
          console.error('Failed to dispatch appointment notification:', e);
        }
      }

      showToast(`Appointment status updated to ${newStatus.toUpperCase()}`);
      setActionModal(null);
      setSelectedAppt(null);
      setActionNotes('');
      fetchAppointments();
    } catch (err) {
      showToast('Error updating appointment: ' + err.message);
    }
    setSubmitting(false);
  };

  const formatScheduledTime = (isoString) => {
    if (!isoString) return 'Unscheduled';
    const d = new Date(isoString);
    return d.toLocaleString('en-US', {
      weekday: 'short',
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
    });
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'confirmed':
        return <span className="appt-badge badge-confirmed"><FiCheck /> Confirmed</span>;
      case 'completed':
        return <span className="appt-badge badge-completed"><FiCheckCircle /> Completed</span>;
      case 'cancelled':
        return <span className="appt-badge badge-cancelled"><FiXCircle /> Cancelled</span>;
      case 'pending':
      default:
        return <span className="appt-badge badge-pending"><FiClock /> Pending Review</span>;
    }
  };

  const getAppointmentTypeLabel = (type) => {
    switch (type) {
      case 'shelter_visit':
        return 'Shelter Visit';
      case 'meet_and_greet':
        return 'Meet & Greet';
      default:
        return type ? type.replace('_', ' ') : 'Shelter Visit';
    }
  };

  // Filter appointments
  const filteredAppointments = appointments.filter((a) => {
    const applicantName = a.applicant?.full_name || '';
    const petName = a.pet?.name || '';
    const shelterName = a.shelter?.name || '';
    const q = searchTerm.toLowerCase();

    const matchSearch =
      applicantName.toLowerCase().includes(q) ||
      petName.toLowerCase().includes(q) ||
      shelterName.toLowerCase().includes(q);

    const matchStatus = statusFilter === 'all' || a.status === statusFilter;

    return matchSearch && matchStatus;
  });

  const pendingCount = appointments.filter((a) => a.status === 'pending').length;
  const confirmedCount = appointments.filter((a) => a.status === 'confirmed').length;

  return (
    <div className="appointment-management">
      <div className="appt-header">
        <div>
          <p className="section-subtitle">
            Review and schedule adopter visits and meet-and-greets at Jagna Animal Lover and Rescue Group
          </p>
        </div>
        <div className="header-actions">
          <button className="btn-refresh" onClick={fetchAppointments} title="Refresh schedules">
            <FiRefreshCw className={loading ? 'spin-icon' : ''} /> Refresh
          </button>
        </div>
      </div>

      {toastMessage && (
        <div className="appt-toast">
          <FiCheckCircle className="toast-icon" /> {toastMessage}
        </div>
      )}

      {error && <div className="error-banner">{error}</div>}

      {/* KPI mini row */}
      <div className="appt-kpi-row">
        <div className="appt-kpi-card soft-orange">
          <div className="kpi-icon"><FiClock /></div>
          <div>
            <span className="kpi-label">Pending Requests</span>
            <span className="kpi-value">{pendingCount}</span>
          </div>
        </div>
        <div className="appt-kpi-card soft-blue">
          <div className="kpi-icon"><FiCalendar /></div>
          <div>
            <span className="kpi-label">Confirmed Upcoming</span>
            <span className="kpi-value">{confirmedCount}</span>
          </div>
        </div>
        <div className="appt-kpi-card soft-green">
          <div className="kpi-icon"><FiCheckCircle /></div>
          <div>
            <span className="kpi-label">Total Bookings</span>
            <span className="kpi-value">{appointments.length}</span>
          </div>
        </div>
      </div>

      {/* Control bar */}
      <div className="appt-controls-bar">
        <div className="search-box-wrap">
          <FiSearch className="search-icon" />
          <input
            type="text"
            placeholder="Search by adopter, pet, or shelter..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button className="clear-search-btn" onClick={() => setSearchTerm('')}>
              <FiX />
            </button>
          )}
        </div>

        <div className="filters-wrap">
          <div className="filter-group">
            <span className="filter-label"><FiFilter /> Status:</span>
            <div className="filter-chips">
              {['all', 'pending', 'confirmed', 'completed', 'cancelled'].map((st) => (
                <button
                  key={st}
                  className={`filter-chip ${statusFilter === st ? 'active' : ''}`}
                  onClick={() => setStatusFilter(st)}
                >
                  {st === 'all' ? 'All Bookings' : st.charAt(0).toUpperCase() + st.slice(1)}
                </button>
              ))}
            </div>
          </div>

        </div>
      </div>

      {/* Main Content */}
      {loading ? (
        <div className="loading-state">
          <FiRefreshCw className="spin-icon large-spinner" />
          <p>Loading scheduled appointments...</p>
        </div>
      ) : filteredAppointments.length === 0 ? (
        <div className="empty-state">
          <FiCalendar className="empty-icon" />
          <h3>No appointments found</h3>
          <p>There are no appointments matching your current search or status filter.</p>
        </div>
      ) : (
        <div className="appointments-grid">
          {filteredAppointments.map((appt) => (
            <div className={`appt-card status-${appt.status}`} key={appt.id}>
              <div className="appt-card-top">
                <div className="appt-type-badge">
                  {getAppointmentTypeLabel(appt.appointment_type)}
                </div>
                {getStatusBadge(appt.status)}
              </div>

              <div className="appt-time-banner">
                <FiCalendar className="time-icon" />
                <span className="time-text">{formatScheduledTime(appt.scheduled_at)}</span>
              </div>

              <div className="appt-card-details">
                {/* Pet preview */}
                <div className="appt-detail-row">
                  <div className="pet-avatar-small">
                    {appt.pet?.image_url ? (
                      <img src={appt.pet.image_url} alt={appt.pet.name} />
                    ) : (
                      <MdPets />
                    )}
                  </div>
                  <div className="appt-pet-info">
                    <span className="appt-pet-label">Pet to Visit:</span>
                    <strong className="appt-pet-name">{appt.pet?.name || 'General Visit'}</strong>
                    {appt.pet?.breed && <small>{appt.pet.breed}</small>}
                  </div>
                </div>

                {/* Adopter info */}
                <div className="appt-adopter-info-box">
                  <div className="adopter-info-line">
                    <FiUser className="line-icon" />
                    <strong>{appt.applicant?.full_name || 'Anonymous Adopter'}</strong>
                  </div>
                  {appt.applicant?.email && (
                    <div className="adopter-info-line">
                      <FiMail className="line-icon" />
                      <span>{appt.applicant.email}</span>
                    </div>
                  )}
                  {appt.applicant?.phone && (
                    <div className="adopter-info-line">
                      <FiPhone className="line-icon" />
                      <span>{appt.applicant.phone}</span>
                    </div>
                  )}
                </div>

                {/* Shelter location */}
                <div className="appt-shelter-box">
                  <FiMapPin className="shelter-icon" />
                  <div>
                    <span className="shelter-name">{appt.shelter?.name || 'JALRG Shelter'}</span>
                    <span className="shelter-addr">{appt.shelter?.address || 'Jagna, Bohol'}</span>
                  </div>
                </div>

                {appt.notes && (
                  <div className="appt-notes-box">
                    <span className="notes-title">Notes / Screening:</span>
                    <p>{appt.notes}</p>
                  </div>
                )}
              </div>

              {/* Actions Footer */}
              <div className="appt-card-footer">
                <button
                  className="btn-details"
                  onClick={() => setSelectedAppt(appt)}
                >
                  View Details
                </button>

                <div className="action-btns">
                  {appt.status === 'pending' && (
                    <button
                      className="btn-action confirm"
                      onClick={() => {
                        setActionModal({ type: 'confirm', appt });
                        setActionNotes(appt.notes || '');
                      }}
                    >
                      <FiCheck /> Confirm
                    </button>
                  )}
                  {appt.status === 'confirmed' && (
                    <button
                      className="btn-action complete"
                      onClick={() => {
                        setActionModal({ type: 'complete', appt });
                        setActionNotes(appt.notes || '');
                      }}
                    >
                      <FiCheckCircle /> Complete Visit
                    </button>
                  )}
                  {appt.status !== 'cancelled' && appt.status !== 'completed' && (
                    <button
                      className="btn-action cancel"
                      onClick={() => {
                        setActionModal({ type: 'cancel', appt });
                        setActionNotes(appt.notes || '');
                      }}
                    >
                      <FiX /> Cancel
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Action Modal (Confirm, Complete, Cancel) */}
      {actionModal && (
        <div className="modal-overlay">
          <div className="appt-action-modal">
            <div className="modal-header">
              <div className="modal-title-wrap">
                <FiCalendar className="modal-title-icon" />
                <h3>
                  {actionModal.type === 'confirm' && 'Confirm Visit Appointment'}
                  {actionModal.type === 'complete' && 'Mark Visit as Completed'}
                  {actionModal.type === 'cancel' && 'Cancel Visit Appointment'}
                </h3>
              </div>
              <button className="btn-close-modal" onClick={() => setActionModal(null)}>
                <FiX />
              </button>
            </div>

            <div className="modal-body">
              <p className="modal-desc">
                {actionModal.type === 'confirm' && (
                  <>
                    Confirm visit for <strong>{actionModal.appt.applicant?.full_name || 'adopter'}</strong> to meet{' '}
                    <strong>{actionModal.appt.pet?.name || 'the pet'}</strong> on{' '}
                    <strong>{formatScheduledTime(actionModal.appt.scheduled_at)}</strong>.
                  </>
                )}
                {actionModal.type === 'complete' && (
                  <>
                    Mark this visit as finished. Did the applicant complete their shelter visit and screening interview?
                  </>
                )}
                {actionModal.type === 'cancel' && (
                  <>
                    Are you sure you want to cancel this scheduled appointment? You can add a reason note below.
                  </>
                )}
              </p>

              <div className="form-field">
                <label>Staff Notes / Instructions for Adopter</label>
                <textarea
                  rows={3}
                  placeholder={
                    actionModal.type === 'confirm'
                      ? 'e.g. Please bring a valid government ID. Look for Shelter Officer Maria upon arrival.'
                      : actionModal.type === 'cancel'
                      ? 'e.g. Shelter schedule full, please reschedule for next weekend.'
                      : 'e.g. Adopter completed interview and meet-and-greet with high interest.'
                  }
                  value={actionNotes}
                  onChange={(e) => setActionNotes(e.target.value)}
                />
              </div>
            </div>

            <div className="modal-footer">
              <button
                className="btn-cancel"
                onClick={() => setActionModal(null)}
                disabled={submitting}
              >
                Go Back
              </button>
              {actionModal.type === 'confirm' && (
                <button
                  className="btn-confirm-action"
                  onClick={() => handleUpdateStatus('confirmed', actionNotes)}
                  disabled={submitting}
                >
                  {submitting ? 'Confirming...' : 'Confirm Appointment'}
                </button>
              )}
              {actionModal.type === 'complete' && (
                <button
                  className="btn-complete-action"
                  onClick={() => handleUpdateStatus('completed', actionNotes)}
                  disabled={submitting}
                >
                  {submitting ? 'Updating...' : 'Mark Completed'}
                </button>
              )}
              {actionModal.type === 'cancel' && (
                <button
                  className="btn-cancel-action"
                  onClick={() => handleUpdateStatus('cancelled', actionNotes)}
                  disabled={submitting}
                >
                  {submitting ? 'Cancelling...' : 'Cancel Appointment'}
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Detail Modal */}
      {selectedAppt && (
        <div className="modal-overlay">
          <div className="appt-detail-modal">
            <div className="modal-header">
              <div className="modal-title-wrap">
                <FiCalendar className="modal-title-icon" />
                <h3>Appointment Details</h3>
              </div>
              <button className="btn-close-modal" onClick={() => setSelectedAppt(null)}>
                <FiX />
              </button>
            </div>

            <div className="detail-modal-body">
              <div className="detail-status-banner">
                <div>
                  <span className="sub-label">Current Status:</span>
                  <div>{getStatusBadge(selectedAppt.status)}</div>
                </div>
                <div>
                  <span className="sub-label">Type:</span>
                  <div className="bold-type">{getAppointmentTypeLabel(selectedAppt.appointment_type)}</div>
                </div>
              </div>

              <div className="detail-section">
                <h4>Schedule &amp; Location</h4>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Scheduled For:</span>
                    <strong className="detail-value">{formatScheduledTime(selectedAppt.scheduled_at)}</strong>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Shelter Venue:</span>
                    <strong className="detail-value">{selectedAppt.shelter?.name || 'JALRG Shelter'}</strong>
                    <small>{selectedAppt.shelter?.address}</small>
                  </div>
                </div>
              </div>

              <div className="detail-section">
                <h4>Pet Information</h4>
                <div className="detail-pet-card">
                  {selectedAppt.pet?.image_url && (
                    <img src={selectedAppt.pet.image_url} alt={selectedAppt.pet.name} className="detail-pet-img" />
                  )}
                  <div>
                    <strong>{selectedAppt.pet?.name || 'General Visit'}</strong>
                    <div>{selectedAppt.pet?.breed}</div>
                    <small>{selectedAppt.pet?.type?.toUpperCase()}</small>
                  </div>
                </div>
              </div>

              <div className="detail-section">
                <h4>Applicant Information</h4>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Name:</span>
                    <span className="detail-value">{selectedAppt.applicant?.full_name || 'Anonymous'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Email:</span>
                    <span className="detail-value">{selectedAppt.applicant?.email || 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Phone:</span>
                    <span className="detail-value">{selectedAppt.applicant?.phone || 'N/A'}</span>
                  </div>
                </div>
              </div>

              {selectedAppt.notes && (
                <div className="detail-section">
                  <h4>Staff &amp; Appointment Notes</h4>
                  <p className="detail-notes-text">{selectedAppt.notes}</p>
                </div>
              )}
            </div>

            <div className="modal-footer">
              <button className="btn-cancel" onClick={() => setSelectedAppt(null)}>
                Close
              </button>
              {selectedAppt.status === 'pending' && (
                <button
                  className="btn-confirm-action"
                  onClick={() => {
                    setActionModal({ type: 'confirm', appt: selectedAppt });
                    setActionNotes(selectedAppt.notes || '');
                  }}
                >
                  <FiCheck /> Confirm Visit
                </button>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default AppointmentManagement;
