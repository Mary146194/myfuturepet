import React, { useState, useEffect, useCallback } from 'react';
import { supabase } from '../config/supabaseClient';
import {
  FiSearch, FiRefreshCw, FiTrash2, FiEdit2, FiCheckCircle,
  FiPlus, FiX, FiFilter,
  FiAlertTriangle
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import ImageUploader from './ImageUploader';
import './PetManagement.css';

const DEFAULT_FORM_STATE = {
  name: '',
  type: 'dog',
  breed: '',
  gender: 'male',
  birthdate: '',
  size: 'medium',
  weight_kg: '',
  color: '',
  health_condition: '',
  vaccination_status: 'unvaccinated',
  temperament: '',
  description: '',
  adoption_requirements: 'Valid ID, screening questionnaire, home inspection agreement',
  status: 'available',
  shelter_id: '',
  image_url: '',
  model_url: '',
};

const DEFAULT_FALLBACK_IMAGES = {
  dog: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=800',
  cat: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
};

const getPetDisplayImage = (pet) => {
  if (pet?.image_url && typeof pet.image_url === 'string' && pet.image_url.trim().length > 0) {
    return pet.image_url.trim();
  }
  return DEFAULT_FALLBACK_IMAGES[pet?.type] || DEFAULT_FALLBACK_IMAGES.dog;
};

const handleImgError = (e, petType) => {
  const fallback = DEFAULT_FALLBACK_IMAGES[petType] || DEFAULT_FALLBACK_IMAGES.dog;
  if (e.target.src !== fallback) {
    e.target.src = fallback;
  }
};

function PetManagement() {
  const [pets, setPets] = useState([]);
  const [shelters, setShelters] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('all'); // 'all' | 'dog' | 'cat'
  const [statusFilter, setStatusFilter] = useState('all'); // 'all' | 'available' | 'pending' | 'adopted'
  
  // Modal states
  const [modalMode, setModalMode] = useState(null); // null | 'add' | 'edit'
  const [activePetId, setActivePetId] = useState(null);
  const [formData, setFormData] = useState(DEFAULT_FORM_STATE);
  const [submitting, setSubmitting] = useState(false);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [toastMessage, setToastMessage] = useState('');

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3800);
  };

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const [
        { data: petsData, error: petsError },
        { data: sheltersData, error: sheltersError },
      ] = await Promise.all([
        supabase
          .from('pets')
          .select(`
            *,
            shelter:shelter_id (
              id,
              name,
              address,
              contact_number
            )
          `)
          .order('created_at', { ascending: false }),
        supabase
          .from('shelters')
          .select('id, name')
          .order('name', { ascending: true }),
      ]);

      if (petsError) throw petsError;
      if (sheltersError) throw sheltersError;

      setPets(petsData || []);
      setShelters(sheltersData || []);

      // Default shelter_id for new pet form
      if (sheltersData && sheltersData.length > 0) {
        DEFAULT_FORM_STATE.shelter_id = sheltersData[0].id;
      }
    } catch (err) {
      setError('Failed to fetch pet records: ' + err.message);
      console.error(err);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleOpenAddModal = () => {
    setFormData({
      ...DEFAULT_FORM_STATE,
      shelter_id: shelters.length > 0 ? shelters[0].id : '',
    });
    setActivePetId(null);
    setModalMode('add');
  };

  const handleOpenEditModal = (pet) => {
    setFormData({
      name: pet.name || '',
      type: pet.type || 'dog',
      breed: pet.breed || '',
      gender: pet.gender || 'male',
      birthdate: pet.birthdate ? pet.birthdate.split('T')[0] : '',
      size: pet.size || 'medium',
      weight_kg: pet.weight_kg !== null && pet.weight_kg !== undefined ? String(pet.weight_kg) : '',
      color: pet.color || '',
      health_condition: pet.health_condition || '',
      vaccination_status: pet.vaccination_status || 'unvaccinated',
      temperament: pet.temperament || '',
      description: pet.description || '',
      adoption_requirements: pet.adoption_requirements || '',
      status: pet.status || 'available',
      shelter_id: pet.shelter_id || (shelters[0]?.id || ''),
      image_url: pet.image_url || '',
      model_url: pet.model_url || '',
    });
    setActivePetId(pet.id);
    setModalMode('edit');
  };

  const handleSavePet = async (e) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      showToast('Please provide a pet name.');
      return;
    }
    if (!formData.shelter_id) {
      showToast('Please select an assigned rescue shelter.');
      return;
    }

    let parsedWeight = null;
    if (formData.weight_kg !== '' && formData.weight_kg !== null && formData.weight_kg !== undefined) {
      parsedWeight = parseFloat(formData.weight_kg);
      if (isNaN(parsedWeight) || parsedWeight <= 0) {
        showToast('Please enter a valid positive number for weight (kg).');
        return;
      }
    }

    setSubmitting(true);
    try {
      const payload = {
        name: formData.name.trim(),
        type: formData.type,
        breed: formData.breed.trim() || null,
        gender: formData.gender,
        birthdate: formData.birthdate || null,
        size: formData.size,
        weight_kg: parsedWeight,
        color: formData.color.trim() || null,
        health_condition: formData.health_condition.trim() || null,
        vaccination_status: formData.vaccination_status,
        temperament: formData.temperament.trim() || null,
        description: formData.description.trim() || null,
        adoption_requirements: formData.adoption_requirements.trim() || null,
        status: formData.status,
        shelter_id: formData.shelter_id,
        image_url: formData.image_url.trim() || null,
        model_url: formData.model_url.trim() || null,
      };

      if (modalMode === 'add') {
        const { error: insertError } = await supabase
          .from('pets')
          .insert([payload]);
        if (insertError) throw insertError;
        showToast(`Pet "${formData.name}" added to adoptable listings successfully.`);
      } else {
        const { error: updateError } = await supabase
          .from('pets')
          .update(payload)
          .eq('id', activePetId);
        if (updateError) throw updateError;
        showToast(`Pet "${formData.name}" profile updated successfully.`);
      }

      setModalMode(null);
      fetchData();
    } catch (err) {
      showToast('Error saving pet record: ' + err.message);
      console.error(err);
    }
    setSubmitting(false);
  };

  const handleDeletePet = async () => {
    if (!deleteTarget) return;
    setSubmitting(true);
    try {
      const { error: deleteError } = await supabase
        .from('pets')
        .delete()
        .eq('id', deleteTarget.id);

      if (deleteError) throw deleteError;

      showToast(`Pet record "${deleteTarget.name}" removed.`);
      setDeleteTarget(null);
      fetchData();
    } catch (err) {
      showToast('Failed to delete pet: ' + err.message);
    }
    setSubmitting(false);
  };

  const handleStatusChange = async (petId, newStatus) => {
    try {
      const { error: updateError } = await supabase
        .from('pets')
        .update({ status: newStatus })
        .eq('id', petId);

      if (updateError) throw updateError;
      showToast(`Status updated to ${newStatus}.`);
      setPets((prev) =>
        prev.map((p) => (p.id === petId ? { ...p, status: newStatus } : p))
      );
    } catch (err) {
      showToast('Error changing status: ' + err.message);
    }
  };

  // Filter Logic
  const filteredPets = pets.filter((pet) => {
    const matchSearch =
      pet.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      pet.breed?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      pet.color?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      pet.shelter?.name?.toLowerCase().includes(searchTerm.toLowerCase());

    const matchType = typeFilter === 'all' || pet.type === typeFilter;
    const matchStatus = statusFilter === 'all' || pet.status === statusFilter;

    return matchSearch && matchType && matchStatus;
  });

  const getStatusBadgeClass = (status) => {
    switch (status) {
      case 'available':
        return 'pet-status-badge status-available';
      case 'pending':
        return 'pet-status-badge status-pending';
      case 'adopted':
        return 'pet-status-badge status-adopted';
      case 'removed':
        return 'pet-status-badge status-removed';
      default:
        return 'pet-status-badge';
    }
  };

  return (
    <div className="pet-management">
      <div className="pet-mgmt-header">
        <div>
          <p className="section-subtitle">
            Manage adoptable rescue animals, health records, and adoption status for Jagna Animal Lover and Rescue Group
          </p>
        </div>
        <div className="header-actions">
          <button className="btn-refresh" onClick={fetchData} title="Refresh records">
            <FiRefreshCw className={loading ? 'spin-icon' : ''} /> Refresh
          </button>
          <button className="btn-primary-add" onClick={handleOpenAddModal}>
            <FiPlus /> Add New Pet
          </button>
        </div>
      </div>

      {toastMessage && (
        <div className="pet-toast">
          <FiCheckCircle className="toast-icon" /> {toastMessage}
        </div>
      )}

      {error && <div className="error-banner">{error}</div>}

      {/* Control Bar: Search, Filters & View Toggle */}
      <div className="pet-controls-bar">
        <div className="search-box-wrap">
          <FiSearch className="search-icon" />
          <input
            type="text"
            placeholder="Search by name, breed, color, or shelter..."
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
          {/* Type Filter */}
          <div className="filter-group">
            <span className="filter-label"><FiFilter /> Type:</span>
            <div className="filter-chips">
              {['all', 'dog', 'cat'].map((t) => (
                <button
                  key={t}
                  className={`filter-chip ${typeFilter === t ? 'active' : ''}`}
                  onClick={() => setTypeFilter(t)}
                >
                  {t === 'all' ? 'All Types' : t.charAt(0).toUpperCase() + t.slice(1) + 's'}
                </button>
              ))}
            </div>
          </div>

          {/* Status Filter */}
          <div className="filter-group">
            <span className="filter-label">Status:</span>
            <div className="filter-chips">
              {['all', 'available', 'pending', 'adopted'].map((s) => (
                <button
                  key={s}
                  className={`filter-chip ${statusFilter === s ? 'active' : ''}`}
                  onClick={() => setStatusFilter(s)}
                >
                  {s.charAt(0).toUpperCase() + s.slice(1)}
                </button>
              ))}
            </div>
          </div>

        </div>
      </div>

      {/* Content Rendering */}
      {loading ? (
        <div className="loading-state">
          <FiRefreshCw className="spin-icon large-spinner" />
          <p>Loading rescue pet records...</p>
        </div>
      ) : filteredPets.length === 0 ? (
        <div className="empty-state">
          <MdPets className="empty-icon" />
          <h3>No pet profiles found</h3>
          <p>Try adjusting your search query or status filter, or add a new rescue pet.</p>
          <button className="btn-secondary-add" onClick={handleOpenAddModal}>
            <FiPlus /> Register a Pet
          </button>
        </div>
      ) : (
        <div className="pets-grid">
          {filteredPets.map((pet) => (
            <div className="pet-card" key={pet.id}>
              <div className="pet-card-image-wrap">
                <img
                  src={getPetDisplayImage(pet)}
                  alt={pet.name}
                  className="pet-card-image"
                  onError={(e) => handleImgError(e, pet.type)}
                />
                {!pet.image_url && (
                  <span className="pet-sample-badge" title="Using default species photo">
                    Default Photo
                  </span>
                )}
                <span className={getStatusBadgeClass(pet.status)}>
                  {pet.status.charAt(0).toUpperCase() + pet.status.slice(1)}
                </span>
                <span className="pet-type-tag">
                  {pet.type.toUpperCase()}
                </span>
              </div>

              <div className="pet-card-body">
                <div className="pet-card-header">
                  <h3 className="pet-name">{pet.name}</h3>
                  <span className="pet-breed">{pet.breed || 'Unknown Breed'}</span>
                </div>

                <div className="pet-attributes-grid">
                  <div className="attr-item">
                    <span className="attr-key">Gender:</span>
                    <span className="attr-val">{pet.gender || 'Unknown'}</span>
                  </div>
                  <div className="attr-item">
                    <span className="attr-key">Size:</span>
                    <span className="attr-val">{pet.size || 'Medium'}</span>
                  </div>
                  <div className="attr-item">
                    <span className="attr-key">Vaccines:</span>
                    <span className="attr-val">
                      {pet.vaccination_status === 'fully_vaccinated' ? 'Fully Vaccinated' : pet.vaccination_status || 'Unknown'}
                    </span>
                  </div>
                  <div className="attr-item">
                    <span className="attr-key">Shelter:</span>
                    <span className="attr-val truncate" title={pet.shelter?.name}>
                      {pet.shelter?.name || 'JALRG Shelter'}
                    </span>
                  </div>
                </div>

                {pet.description && (
                  <p className="pet-card-desc">{pet.description}</p>
                )}

                <div className="pet-card-actions">
                  <select
                    className="status-selector"
                    value={pet.status}
                    onChange={(e) => handleStatusChange(pet.id, e.target.value)}
                  >
                    <option value="available">Available</option>
                    <option value="pending">Pending</option>
                    <option value="adopted">Adopted</option>
                    <option value="removed">Removed</option>
                  </select>

                  <div className="action-buttons-group">
                    <button
                      className="btn-edit"
                      onClick={() => handleOpenEditModal(pet)}
                      title="Edit Pet Profile"
                    >
                      <FiEdit2 /> Edit
                    </button>
                    <button
                      className="btn-delete"
                      onClick={() => setDeleteTarget(pet)}
                      title="Remove Listing"
                    >
                      <FiTrash2 />
                    </button>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Add / Edit Pet Modal */}
      {modalMode && (
        <div className="modal-overlay">
          <div className="pet-modal-card">
            <div className="modal-header">
              <div className="modal-title-wrap">
                <MdPets className="modal-title-icon" />
                <h3>{modalMode === 'add' ? 'Register New Rescue Pet' : `Edit Profile: ${formData.name}`}</h3>
              </div>
              <button className="btn-close-modal" onClick={() => setModalMode(null)}>
                <FiX />
              </button>
            </div>

            <form onSubmit={handleSavePet} className="pet-form">
              <div className="form-scroll-content">
                {/* Basic Details */}
                <h4 className="form-section-title">Basic Information</h4>
                <div className="form-grid-2">
                  <div className="form-field">
                    <label>Pet Name *</label>
                    <input
                      type="text"
                      required
                      placeholder="e.g. Bantay, Muning, Max"
                      value={formData.name}
                      onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    />
                  </div>
                  <div className="form-field">
                    <label>Species / Type *</label>
                    <select
                      value={formData.type}
                      onChange={(e) => setFormData({ ...formData, type: e.target.value })}
                    >
                      <option value="dog">Dog</option>
                      <option value="cat">Cat</option>
                    </select>
                  </div>
                </div>

                <div className="form-grid-3">
                  <div className="form-field">
                    <label>Breed</label>
                    <input
                      type="text"
                      placeholder="e.g. Aspin (native), Puspin, Terrier"
                      value={formData.breed}
                      onChange={(e) => setFormData({ ...formData, breed: e.target.value })}
                    />
                  </div>
                  <div className="form-field">
                    <label>Gender</label>
                    <select
                      value={formData.gender}
                      onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                    >
                      <option value="male">Male</option>
                      <option value="female">Female</option>
                    </select>
                  </div>
                  <div className="form-field">
                    <label>Estimated Birthdate</label>
                    <input
                      type="date"
                      value={formData.birthdate}
                      onChange={(e) => setFormData({ ...formData, birthdate: e.target.value })}
                    />
                  </div>
                </div>

                <div className="form-grid-3">
                  <div className="form-field">
                    <label>Size</label>
                    <select
                      value={formData.size}
                      onChange={(e) => setFormData({ ...formData, size: e.target.value })}
                    >
                      <option value="small">Small</option>
                      <option value="medium">Medium</option>
                      <option value="large">Large</option>
                    </select>
                  </div>
                  <div className="form-field">
                    <label>Weight (kg)</label>
                    <input
                      type="number"
                      step="0.1"
                      placeholder="e.g. 12.5"
                      value={formData.weight_kg}
                      onChange={(e) => setFormData({ ...formData, weight_kg: e.target.value })}
                    />
                  </div>
                  <div className="form-field">
                    <label>Color / Markings</label>
                    <input
                      type="text"
                      placeholder="e.g. Brown, White &amp; Black"
                      value={formData.color}
                      onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                    />
                  </div>
                </div>

                {/* Health & Medical */}
                <h4 className="form-section-title">Health &amp; Medical Records</h4>
                <div className="form-grid-2">
                  <div className="form-field">
                    <label>Vaccination Status</label>
                    <select
                      value={formData.vaccination_status}
                      onChange={(e) => setFormData({ ...formData, vaccination_status: e.target.value })}
                    >
                      <option value="fully_vaccinated">Fully Vaccinated</option>
                      <option value="partial">Partially Vaccinated</option>
                      <option value="unvaccinated">Unvaccinated</option>
                    </select>
                  </div>
                  <div className="form-field">
                    <label>Adoption Status</label>
                    <select
                      value={formData.status}
                      onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                    >
                      <option value="available">Available for Adoption</option>
                      <option value="pending">Pending Review</option>
                      <option value="adopted">Adopted (Happy Tail)</option>
                      <option value="removed">Removed / Archived</option>
                    </select>
                  </div>
                </div>

                <div className="form-field">
                  <label>Health Condition &amp; Veterinary Notes</label>
                  <input
                    type="text"
                    placeholder="e.g. Dewormed, neutered/spayed, healthy, hip-checked"
                    value={formData.health_condition}
                    onChange={(e) => setFormData({ ...formData, health_condition: e.target.value })}
                  />
                </div>

                <div className="form-field">
                  <label>Temperament &amp; Behavioral Traits</label>
                  <input
                    type="text"
                    placeholder="e.g. Friendly, calm, energetic, good with children"
                    value={formData.temperament}
                    onChange={(e) => setFormData({ ...formData, temperament: e.target.value })}
                  />
                </div>

                {/* Shelter & Description */}
                <h4 className="form-section-title">Shelter Assignment &amp; Profile Details</h4>
                <div className="form-field">
                  <label>Partner Rescue Shelter *</label>
                  <select
                    required
                    value={formData.shelter_id}
                    onChange={(e) => setFormData({ ...formData, shelter_id: e.target.value })}
                  >
                    {shelters.map((s) => (
                      <option key={s.id} value={s.id}>{s.name}</option>
                    ))}
                  </select>
                </div>

                <div className="form-field">
                  <label>About Pet / Rescue Story</label>
                  <textarea
                    rows={3}
                    placeholder="Describe how the pet was rescued, personality quirks, and ideal family environment..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  />
                </div>

                <div className="form-field">
                  <label>Adoption Requirements (Non-Commercial)</label>
                  <textarea
                    rows={2}
                    placeholder="e.g. Valid government ID, home check agreement, fenced yard preferred..."
                    value={formData.adoption_requirements}
                    onChange={(e) => setFormData({ ...formData, adoption_requirements: e.target.value })}
                  />
                </div>

                {/* Media & 3D AR Model */}
                <h4 className="form-section-title">Media &amp; AR 3D Model</h4>
                <div className="form-grid-2">
                  <div className="form-field" style={{ gridColumn: 'span 2' }}>
                    <label>Pet Photo</label>
                    <ImageUploader
                      currentUrl={formData.image_url}
                      onChange={(url) => setFormData({ ...formData, image_url: url })}
                      petName={formData.name || 'Pet'}
                      petType={formData.type}
                    />
                  </div>
                  <div className="form-field">
                    <label>AR 3D Model URL (.glb / .gltf)</label>
                    <input
                      type="url"
                      placeholder="https://... path to 3D asset in Supabase storage"
                      value={formData.model_url}
                      onChange={(e) => setFormData({ ...formData, model_url: e.target.value })}
                    />
                  </div>
                </div>
              </div>

              <div className="modal-footer">
                <button
                  type="button"
                  className="btn-cancel"
                  onClick={() => setModalMode(null)}
                  disabled={submitting}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="btn-save-pet"
                  disabled={submitting}
                >
                  {submitting ? 'Saving Pet...' : (modalMode === 'add' ? 'Publish Pet Listing' : 'Save Changes')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteTarget && (
        <div className="modal-overlay">
          <div className="delete-modal-card">
            <div className="delete-icon-wrap">
              <FiAlertTriangle />
            </div>
            <h3>Remove Pet Profile?</h3>
            <p>
              Are you sure you want to delete <strong>{deleteTarget.name}</strong> from the database?
              All associated application references will also be removed.
            </p>
            <div className="delete-modal-actions">
              <button
                className="btn-cancel"
                onClick={() => setDeleteTarget(null)}
                disabled={submitting}
              >
                Cancel
              </button>
              <button
                className="btn-confirm-delete"
                onClick={handleDeletePet}
                disabled={submitting}
              >
                {submitting ? 'Deleting...' : 'Yes, Delete Record'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default PetManagement;
