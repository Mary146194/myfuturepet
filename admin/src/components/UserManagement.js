import React, { useState, useEffect, useCallback } from 'react';
import { supabase } from '../config/supabaseClient';
import {
  FiSearch, FiRefreshCw, FiTrash2, FiShield,
  FiCheck, FiX, FiAlertTriangle, FiUser,
} from 'react-icons/fi';
import './UserManagement.css';

function UserManagement() {
  const [profiles, setProfiles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('all'); // 'all' | 'admin' | 'adopter'
  const [toastMessage, setToastMessage] = useState('');

  // Confirmation Modal State
  const [modalAction, setModalAction] = useState(null); // { type: 'role'|'delete', user: {...} }

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3500);
  };

  const fetchUsers = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      let { data: profileData, error: profileErr } = await supabase
        .rpc('admin_list_profiles')
        .order('created_at', { ascending: false });

      if (profileErr) {
        // Fallback for pre-006 migration compatibility
        const fallback = await supabase
          .from('profiles')
          .select('id, full_name, email, created_at, role')
          .order('created_at', { ascending: false });
        if (fallback.error) throw new Error(fallback.error.message);
        profileData = fallback.data;
      }
      setProfiles(profileData || []);
    } catch (err) {
      setError(err.message || 'Failed to fetch users');
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  const handleConfirmRoleChange = async () => {
    if (!modalAction || modalAction.type !== 'role') return;
    const { user } = modalAction;
    const isAdmin = user.role === 'admin';

    if (isAdmin) {
      const { count: adminCount, error: countError } = await supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true })
        .eq('role', 'admin');

      if (countError) {
        showToast('Error checking admin accounts: ' + countError.message);
        setModalAction(null);
        return;
      }
      if ((adminCount ?? 0) <= 1) {
        showToast('Cannot remove the last administrator account.');
        setModalAction(null);
        return;
      }
    }

    try {
      const newRole = isAdmin ? 'adopter' : 'admin';
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ role: newRole })
        .eq('id', user.id);

      if (updateError) throw updateError;
      showToast(`Role updated: ${user.full_name || user.email} is now ${newRole === 'admin' ? 'an Administrator' : 'an Adopter'}.`);
      fetchUsers();
    } catch (err) {
      showToast('Failed to update role: ' + err.message);
    }
    setModalAction(null);
  };

  const handleConfirmDelete = async () => {
    if (!modalAction || modalAction.type !== 'delete') return;
    const { user } = modalAction;

    if (user.role === 'admin') {
      showToast('Admin accounts cannot be deleted directly. Revoke admin privileges first.');
      setModalAction(null);
      return;
    }

    try {
      const { data: removed, error: deleteError } = await supabase
        .from('profiles')
        .delete()
        .eq('id', user.id)
        .select('id');

      if (deleteError) throw deleteError;
      // Row-level security blocks profile deletes without an error, only zero rows.
      if (!removed || removed.length === 0) {
        throw new Error('accounts can only be removed from the Supabase dashboard (Authentication → Users).');
      }
      showToast(`User ${user.full_name || user.email} deleted successfully.`);
      setProfiles((prev) => prev.filter((u) => u.id !== user.id));
    } catch (err) {
      showToast('Failed to delete user: ' + err.message);
    }
    setModalAction(null);
  };

  const getInitials = (name) => {
    if (!name) return 'U';
    return name
      .split(' ')
      .map((w) => w[0])
      .filter(Boolean)
      .slice(0, 2)
      .join('')
      .toUpperCase();
  };

  // Avatar color generator based on text
  const getAvatarGradient = (str) => {
    const gradients = [
      'linear-gradient(145deg, #FF6B35, #FF8C5A)',
      'linear-gradient(145deg, #3B82F6, #60A5FA)',
      'linear-gradient(145deg, #10B981, #34D399)',
      'linear-gradient(145deg, #8B5CF6, #A78BFA)',
      'linear-gradient(145deg, #EC4899, #F472B6)',
    ];
    let hash = 0;
    for (let i = 0; i < (str || '').length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
    }
    const index = Math.abs(hash) % gradients.length;
    return gradients[index];
  };

  const filteredUsers = profiles.filter((user) => {
    const matchesSearch =
      (user.email || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
      (user.full_name || '').toLowerCase().includes(searchTerm.toLowerCase());

    const matchesRole =
      roleFilter === 'all'
        ? true
        : roleFilter === 'admin'
        ? user.role === 'admin'
        : user.role !== 'admin';

    return matchesSearch && matchesRole;
  });

  const adminCount = profiles.filter((u) => u.role === 'admin').length;
  const adopterCount = profiles.filter((u) => u.role !== 'admin').length;

  if (loading) return <div className="loading">Loading users...</div>;

  return (
    <div className="user-management">
      <p className="section-subtitle">
        Manage registered adopter profiles, assign administrative roles, and maintain accounts.
      </p>

      {toastMessage && (
        <div className="user-toast">
          <FiCheck className="toast-icon" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Role Filter Tabs & Stats Bar */}
      <div className="user-filter-bar">
        <div className="role-filter-group">
          <button
            className={`filter-chip ${roleFilter === 'all' ? 'active' : ''}`}
            onClick={() => setRoleFilter('all')}
          >
            All Users <span className="chip-count">{profiles.length}</span>
          </button>
          <button
            className={`filter-chip ${roleFilter === 'admin' ? 'active' : ''}`}
            onClick={() => setRoleFilter('admin')}
          >
            <FiShield /> Administrators <span className="chip-count">{adminCount}</span>
          </button>
          <button
            className={`filter-chip ${roleFilter === 'adopter' ? 'active' : ''}`}
            onClick={() => setRoleFilter('adopter')}
          >
            <FiUser /> Adopters <span className="chip-count">{adopterCount}</span>
          </button>
        </div>

        <button onClick={fetchUsers} className="refresh-users-btn">
          <FiRefreshCw /> Refresh
        </button>
      </div>

      {/* Search Input Bar */}
      <div className="search-box">
        <div className="search-input-wrapper">
          <FiSearch className="search-icon" />
          <input
            type="text"
            placeholder="Search users by name, email, or user ID..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          {searchTerm && (
            <button className="clear-search-btn" onClick={() => setSearchTerm('')}>
              <FiX />
            </button>
          )}
        </div>
        <span className="search-count-label">
          Showing {filteredUsers.length} of {profiles.length} users
        </span>
      </div>

      {error && <div className="error-message">{error}</div>}

      {/* Modern Users Table */}
      <div className="users-table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>User Profile</th>
              <th>Email Address</th>
              <th>System Role</th>
              <th>Registration Date</th>
              <th className="th-actions">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.length > 0 ? (
              filteredUsers.map((user) => {
                const isAdmin = user.role === 'admin';
                return (
                  <tr key={user.id}>
                    <td>
                      <div className="user-info-cell">
                        <div
                          className="user-avatar-circle"
                          style={{ background: getAvatarGradient(user.email || user.full_name) }}
                        >
                          {getInitials(user.full_name)}
                        </div>
                        <div className="user-text-meta">
                          <strong className="user-name-text">{user.full_name || 'Unnamed User'}</strong>
                          <span className="user-id-mono">ID: {user.id.slice(0, 8)}</span>
                        </div>
                      </div>
                    </td>
                    <td>
                      <span className="user-email-text">{user.email}</span>
                    </td>
                    <td>
                      <span className={`role-pill ${isAdmin ? 'role-admin' : 'role-adopter'}`}>
                        {isAdmin ? <><FiShield /> Admin</> : <><FiUser /> Adopter</>}
                      </span>
                    </td>
                    <td>
                      <span className="user-date-text">{new Date(user.created_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </td>
                    <td className="actions">
                      {/* Toggle Admin Role */}
                      <button
                        onClick={() => setModalAction({ type: 'role', user })}
                        className={`action-btn-role ${isAdmin ? 'role-demote' : 'role-promote'}`}
                        title={isAdmin ? 'Revoke Admin Access' : 'Grant Admin Privileges'}
                      >
                        <FiShield />
                        <span>{isAdmin ? 'Revoke' : 'Make Admin'}</span>
                      </button>

                      {/* Delete */}
                      <button
                        onClick={() => setModalAction({ type: 'delete', user })}
                        className="action-btn-delete"
                        title="Delete User Profile"
                      >
                        <FiTrash2 />
                      </button>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="5" className="empty-users-cell">
                  <div className="empty-users-content">
                    <FiUser className="empty-users-icon" />
                    <p>No user accounts matched your search criteria.</p>
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Styled In-App Confirmation Modal */}
      {modalAction && (
        <div className="user-modal-backdrop" onClick={() => setModalAction(null)}>
          <div className="user-modal-card" onClick={(e) => e.stopPropagation()}>
            <div className={`user-modal-icon-wrap ${modalAction.type === 'delete' ? 'icon-danger' : 'icon-primary'}`}>
              {modalAction.type === 'delete' ? <FiAlertTriangle /> : <FiShield />}
            </div>

            <div className="user-modal-body">
              <h3>
                {modalAction.type === 'delete'
                  ? 'Confirm Profile Deletion'
                  : modalAction.user.role === 'admin'
                  ? 'Revoke Admin Privileges'
                  : 'Grant Admin Privileges'}
              </h3>
              <p>
                {modalAction.type === 'delete'
                  ? `Are you sure you want to delete profile for ${modalAction.user.full_name || modalAction.user.email}? This action is permanent and cannot be undone.`
                  : modalAction.user.role === 'admin'
                  ? `Demote ${modalAction.user.full_name || modalAction.user.email} back to standard Adopter status? They will lose access to the administrative dashboard.`
                  : `Promote ${modalAction.user.full_name || modalAction.user.email} to Admin? They will be granted full access to the admin console.`}
              </p>
            </div>

            <div className="user-modal-actions">
              <button className="modal-btn-cancel" onClick={() => setModalAction(null)}>
                Cancel
              </button>
              <button
                className={`modal-btn-confirm ${modalAction.type === 'delete' ? 'btn-danger' : 'btn-primary'}`}
                onClick={modalAction.type === 'delete' ? handleConfirmDelete : handleConfirmRoleChange}
              >
                {modalAction.type === 'delete' ? 'Delete Profile' : 'Confirm Role Change'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default UserManagement;
