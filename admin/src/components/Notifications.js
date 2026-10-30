import React, { useState, useEffect } from 'react';
import { supabase } from '../config/supabaseClient';
import { 
  FiSend, 
  FiRefreshCw, 
  FiBell, 
  FiTrash2, 
  FiCheckCircle, 
  FiAlertTriangle, 
  FiSmartphone,
  FiZap,
  FiCalendar,
  FiGlobe,
  FiHome,
  FiUser,
  FiWifi,
  FiBattery,
  FiBox,
  FiUsers,
  FiChevronRight
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import './Notifications.css';

function Notifications() {
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [recipientType, setRecipientType] = useState('all');
  const [loading, setLoading] = useState(false);
  const [announcements, setAnnouncements] = useState([]);
  const [historyLoading, setHistoryLoading] = useState(true);
  const [historyFilter, setHistoryFilter] = useState('all');

  // Custom in-app toast
  const [toast, setToast] = useState(null);

  // In-app delete confirmation modal
  const [deleteModal, setDeleteModal] = useState({
    isOpen: false,
    item: null,
    loading: false,
  });

  const showToast = (msg, type = 'success') => {
    setToast({ message: msg, type });
    setTimeout(() => setToast(null), 3800);
  };

  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const fetchAnnouncements = async () => {
    setHistoryLoading(true);
    try {
      const { data, error } = await supabase
        .from('announcements')
        .select(`
          id,
          title,
          body,
          audience,
          image_url,
          created_at,
          creator:created_by (full_name)
        `)
        .order('created_at', { ascending: false })
        .limit(30);

      if (error) {
        console.error('Error fetching announcements:', error);
        setAnnouncements([]);
      } else {
        setAnnouncements(data || []);
      }
    } catch (err) {
      console.error(err);
      setAnnouncements([]);
    }
    setHistoryLoading(false);
  };

  const applyPreset = (presetType) => {
    if (presetType === 'event') {
      setTitle('Weekend Pet Adoption Day at Jagna!');
      setMessage('Join us this Saturday at the Jagna municipal grounds! Meet adoptable dogs and cats in person and explore our AR visualization booths.');
      setRecipientType('all');
    } else if (presetType === 'urgency') {
      setTitle('Urgent Need: Foster Homes for Rescued Puppies');
      setMessage('Our rescue shelter just took in a litter of 5 abandoned puppies. If you can provide a safe temporary foster space, please submit a screening application.');
      setRecipientType('adopters');
    } else if (presetType === 'feature') {
      setTitle('New AR Core 3D Pet Viewing Feature Released');
      setMessage('Update your My Future Pet mobile app to the latest build to experience real-time 3D pet scaling and spatial placement in your room!');
      setRecipientType('all');
    } else if (presetType === 'staff') {
      setTitle('Shelter Protocol: Weekly Health Checkup Schedule');
      setMessage('Reminder to shelter caretakers: Please log all vaccination dates and temperament reports in the admin portal prior to Friday afternoon.');
      setRecipientType('staff');
    }
    showToast('Template preset applied to editor');
  };

  const handleSendNotification = async (e) => {
    e.preventDefault();
    
    if (!title.trim() || !message.trim()) {
      showToast('Please provide both an announcement title and message content', 'error');
      return;
    }

    setLoading(true);

    try {
      const { data: { user }, error: userError } = await supabase.auth.getUser();
      
      if (userError || !user) {
        showToast('Could not verify active admin session', 'error');
        setLoading(false);
        return;
      }

      const { error: insertError } = await supabase
        .from('announcements')
        .insert([
          {
            title: title.trim(),
            body: message.trim(),
            audience: recipientType,
            created_by: user.id,
          }
        ]);

      if (insertError) {
        showToast('Failed to broadcast: ' + insertError.message, 'error');
        setLoading(false);
        return;
      }

      showToast('Announcement broadcasted to mobile users successfully!');
      setTitle('');
      setMessage('');
      setRecipientType('all');
      fetchAnnouncements();
    } catch (err) {
      showToast('Failed to send announcement', 'error');
      console.error(err);
    }

    setLoading(false);
  };

  const openDeleteModal = (announcement) => {
    setDeleteModal({
      isOpen: true,
      item: announcement,
      loading: false,
    });
  };

  const closeDeleteModal = () => {
    setDeleteModal({
      isOpen: false,
      item: null,
      loading: false,
    });
  };

  const handleConfirmDelete = async () => {
    if (!deleteModal.item) return;
    setDeleteModal((prev) => ({ ...prev, loading: true }));

    try {
      const { data: removed, error: deleteError } = await supabase
        .from('announcements')
        .delete()
        .eq('id', deleteModal.item.id)
        .select('id');

      // Row-level security returns no error when it blocks a delete, only zero rows.
      if (deleteError || !removed || removed.length === 0) {
        showToast('Error removing announcement: ' + (deleteError?.message || 'you do not have permission to delete it.'), 'error');
        setDeleteModal((prev) => ({ ...prev, loading: false }));
        return;
      }

      setAnnouncements((prev) => prev.filter((a) => a.id !== deleteModal.item.id));
      showToast('Announcement removed successfully');
      closeDeleteModal();
    } catch (err) {
      showToast('Failed to delete announcement', 'error');
      console.error(err);
      setDeleteModal((prev) => ({ ...prev, loading: false }));
    }
  };

  const filteredAnnouncements = announcements.filter((a) => {
    if (historyFilter === 'all') return true;
    return a.audience === historyFilter;
  });

  return (
    <div className="notifications">
      {/* In-app Toast */}
      {toast && (
        <div className={`notifications-toast toast-${toast.type}`}>
          {toast.type === 'error' ? <FiAlertTriangle /> : <FiCheckCircle />}
          <span>{toast.message}</span>
        </div>
      )}

      <div className="notifications-header-area">
        <div>
          <p className="section-subtitle">
            Publish official updates, rescue notices, and adoption reminders to mobile app adopters and shelter staff.
          </p>
        </div>
      </div>

      {/* Two Column Layout: Composer on left, Mobile Mockup on right */}
      <div className="notifications-split-grid">
        {/* Left Column: Form & Presets */}
        <div className="composer-column">
          <div className="composer-card">
            <div className="composer-header">
              <h3><FiBell /> Compose New Broadcast</h3>
              <p>Craft your alert below. Use presets for quick drafting.</p>
            </div>

            {/* Presets Bar */}
            <div className="presets-bar">
              <span className="presets-label"><FiZap /> Quick Templates:</span>
              <div className="presets-chips">
                <button type="button" className="preset-chip" onClick={() => applyPreset('event')}>
                  <FiCalendar /> Adoption Event
                </button>
                <button type="button" className="preset-chip" onClick={() => applyPreset('urgency')}>
                  <FiAlertTriangle /> Urgent Foster
                </button>
                <button type="button" className="preset-chip" onClick={() => applyPreset('feature')}>
                  <FiBox /> AR Feature
                </button>
                <button type="button" className="preset-chip" onClick={() => applyPreset('staff')}>
                  <FiUsers /> Shelter Staff
                </button>
              </div>
            </div>

            <form onSubmit={handleSendNotification} className="broadcast-form">
              {/* Audience Selector Chips */}
              <div className="form-group">
                <label>Target Audience</label>
                <div className="audience-toggle-group">
                  <button
                    type="button"
                    className={`audience-pill ${recipientType === 'all' ? 'active' : ''}`}
                    onClick={() => setRecipientType('all')}
                  >
                    <FiGlobe /> All Users (Public)
                  </button>
                  <button
                    type="button"
                    className={`audience-pill ${recipientType === 'adopters' ? 'active' : ''}`}
                    onClick={() => setRecipientType('adopters')}
                  >
                    <MdPets /> Potential Adopters
                  </button>
                  <button
                    type="button"
                    className={`audience-pill ${recipientType === 'staff' ? 'active' : ''}`}
                    onClick={() => setRecipientType('staff')}
                  >
                    <FiHome /> Shelter Staff Only
                  </button>
                </div>
              </div>

              <div className="form-group">
                <label>Announcement Title</label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="e.g., Weekend Pet Adoption Fair at Jagna Grounds!"
                  maxLength={100}
                  required
                />
                <span className="input-char-count">{title.length}/100</span>
              </div>

              <div className="form-group">
                <label>Message Content</label>
                <textarea
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  placeholder="Describe your announcement in detail. Include times, locations, or actions requested from adopters..."
                  rows="5"
                  maxLength={500}
                  required
                />
                <span className="input-char-count">{message.length}/500</span>
              </div>

              <div className="form-actions">
                <button type="submit" disabled={loading} className="send-btn">
                  <FiSend /> {loading ? 'Broadcasting...' : 'Broadcast to Mobile Users'}
                </button>
              </div>
            </form>
          </div>
        </div>

        {/* Right Column: Live Mobile Preview */}
        <div className="preview-column">
          <div className="phone-mockup-wrapper">
            <div className="preview-label-tag">
              <FiSmartphone /> Live Mobile App Preview (Android 9.0+)
            </div>

            {/* Android Device Mockup */}
            <div className="phone-frame">
              {/* Phone Status Bar */}
              <div className="phone-status-bar">
                <span>9:41 AM</span>
                <div className="phone-status-icons">
                  <FiWifi />
                  <FiBattery />
                </div>
              </div>

              {/* Phone App Bar */}
              <div className="phone-app-bar">
                <div className="app-brand">
                  <span className="app-paw"><MdPets /></span>
                  <span className="app-name">My Future Pet</span>
                </div>
                <div className="phone-bell-icon">
                  <FiBell />
                  <span className="bell-badge">1</span>
                </div>
              </div>

              {/* Phone App Screen Body */}
              <div className="phone-screen-body">
                <div className="phone-section-title">
                  <span>Notifications</span>
                  <small>Today</small>
                </div>

                {/* Live Rendered Notification Card */}
                <div className="phone-notification-card">
                  <div className="card-top-row">
                    <div className="app-micro-icon">
                      <MdPets />
                    </div>
                    <div className="notif-header-text">
                      <span className="notif-sender">My Future Pet • Announcement</span>
                      <span className="notif-time">Just Now</span>
                    </div>
                  </div>

                  <div className="notif-audience-badge">
                    {recipientType === 'all' && <><FiGlobe /> Public Broadcast</>}
                    {recipientType === 'adopters' && <><MdPets /> For Adopters</>}
                    {recipientType === 'staff' && <><FiHome /> Shelter Staff Only</>}
                  </div>

                  <h5 className="notif-title">
                    {title.trim() || 'Announcement Title Appears Here...'}
                  </h5>

                  <p className="notif-body">
                    {message.trim() || 'Your announcement text will render in real-time on adopters’ mobile screens just like this.'}
                  </p>

                  <div className="notif-footer-hint">
                    <span>Tap to view full details</span>
                    <FiChevronRight />
                  </div>
                </div>

                {/* Dummy Previous Notification */}
                <div className="phone-notification-card dim-card">
                  <div className="card-top-row">
                    <div className="app-micro-icon dim-icon">
                      <MdPets />
                    </div>
                    <div className="notif-header-text">
                      <span className="notif-sender">JALRG Shelter</span>
                      <span className="notif-time">2d ago</span>
                    </div>
                  </div>
                  <h5 className="notif-title dim-title">Application Status Updated</h5>
                  <p className="notif-body dim-body">Your screening application for Bella has been reviewed.</p>
                </div>
              </div>

              {/* Phone Nav Bar Pill */}
              <div className="phone-bottom-nav">
                <div className="nav-home-indicator" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Announcements History Table / Feed */}
      <div className="recent-announcements">
        <div className="announcements-header">
          <div>
            <h3>Broadcast History ({announcements.length})</h3>
            <p className="history-subtext">Past platform announcements published to app users</p>
          </div>

          <div className="history-controls">
            <div className="history-filter-chips">
              <button 
                className={`hist-chip ${historyFilter === 'all' ? 'active' : ''}`}
                onClick={() => setHistoryFilter('all')}
              >
                All ({announcements.length})
              </button>
              <button 
                className={`hist-chip ${historyFilter === 'adopters' ? 'active' : ''}`}
                onClick={() => setHistoryFilter('adopters')}
              >
                Adopters
              </button>
              <button 
                className={`hist-chip ${historyFilter === 'staff' ? 'active' : ''}`}
                onClick={() => setHistoryFilter('staff')}
              >
                Staff
              </button>
            </div>

            <button onClick={fetchAnnouncements} className="refresh-btn" disabled={historyLoading}>
              <FiRefreshCw className={historyLoading ? 'spin-icon' : ''} /> Refresh
            </button>
          </div>
        </div>

        {historyLoading ? (
          <div className="loading-state-box">
            <FiRefreshCw className="spin-icon" />
            <p>Loading announcement logs...</p>
          </div>
        ) : filteredAnnouncements.length > 0 ? (
          <div className="announcement-grid">
            {filteredAnnouncements.map((announcement) => (
              <div key={announcement.id} className="announcement-card-item">
                <div className="announcement-card-top">
                  <span className={`audience-tag audience-${announcement.audience}`}>
                    {announcement.audience === 'all' ? (
                      <><FiGlobe /> All Users</>
                    ) : announcement.audience === 'adopters' ? (
                      <><MdPets /> Adopters</>
                    ) : (
                      <><FiHome /> Staff</>
                    )}
                  </span>
                  <span className="announcement-date">
                    <FiCalendar /> {new Date(announcement.created_at).toLocaleDateString()}
                  </span>
                </div>

                <h4 className="announcement-title">{announcement.title}</h4>
                <p className="announcement-body">{announcement.body}</p>

                <div className="announcement-card-footer">
                  <span className="posted-by">
                    <FiUser /> {announcement.creator?.full_name || 'Admin'}
                  </span>
                  <button 
                    className="delete-announcement-btn"
                    onClick={() => openDeleteModal(announcement)}
                    title="Delete Announcement"
                  >
                    <FiTrash2 /> Remove
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="no-announcements">
            <FiBell className="empty-bell-icon" />
            <h4>No Announcements Found</h4>
            <p>No broadcast announcements match the selected filter.</p>
          </div>
        )}
      </div>

      {/* In-App Delete Confirmation Modal */}
      {deleteModal.isOpen && (
        <div className="user-modal-backdrop" onClick={closeDeleteModal}>
          <div className="delete-confirm-card" onClick={(e) => e.stopPropagation()}>
            <div className="delete-icon-wrapper">
              <FiAlertTriangle />
            </div>
            <h3>Delete Announcement?</h3>
            <p>
              Are you sure you want to remove this announcement? It will no longer be visible on users' mobile feeds.
            </p>
            {deleteModal.item && (
              <div className="item-preview-quote">
                <strong>{deleteModal.item.title}</strong>
              </div>
            )}
            <div className="delete-modal-actions">
              <button 
                className="cancel-btn" 
                onClick={closeDeleteModal}
                disabled={deleteModal.loading}
              >
                Cancel
              </button>
              <button 
                className="confirm-delete-btn" 
                onClick={handleConfirmDelete}
                disabled={deleteModal.loading}
              >
                {deleteModal.loading ? 'Deleting...' : 'Yes, Delete'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Notifications;
