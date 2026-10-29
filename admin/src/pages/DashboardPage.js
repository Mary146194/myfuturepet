import React, { useState, useEffect, useRef, useMemo } from 'react';
import appLogo from '../assets/logo.png';
import {
  FiBarChart2, FiUsers, FiHome, FiClipboard, FiMessageSquare,
  FiFileText, FiBell, FiActivity, FiShield,
  FiChevronDown, FiCalendar, FiLogOut,
  FiMenu, FiX,
  FiRepeat, FiLock, FiEye, FiEyeOff, FiUserCheck,
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import { supabase } from '../config/supabaseClient';
import DashboardOverview from '../components/DashboardOverview';
import UserManagement from '../components/UserManagement';
import PetManagement from '../components/PetManagement';
import AdoptionMonitoring from '../components/AdoptionMonitoring';
import AppointmentManagement from '../components/AppointmentManagement';
import CommunityPosts from '../components/CommunityPosts';
import Notifications from '../components/Notifications';
import Reports from '../components/Reports';
import SystemLogs from '../components/SystemLogs';
import './DashboardPage.css';

function DashboardPage({ user, onLogout }) {
  const [activeTab, setActiveTab] = useState('analytics');
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [profileDropdownOpen, setProfileDropdownOpen] = useState(false);
  const [badgeCounts, setBadgeCounts] = useState({
    users: 0,
    pets: 0,
    pendingAdoptions: 0,
    appointments: 0,
  });

  // Role Switcher States: 'admin' (Super Administrator) vs 'shelter_staff' (JALRG Shelter Staff)
  const [activeRole, setActiveRole] = useState(() => {
    return localStorage.getItem('myfuturepet_active_role') || 'admin';
  });
  const [roleModalOpen, setRoleModalOpen] = useState(false);
  const [targetRole, setTargetRole] = useState(null); // 'admin' | 'shelter_staff'
  const [rolePassword, setRolePassword] = useState('');
  const [rolePasswordError, setRolePasswordError] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isVerifying, setIsVerifying] = useState(false);

  const sidebarRef = useRef(null);
  const profileRef = useRef(null);

  const closeSidebar = () => setSidebarOpen(false);

  const handleOpenRoleModal = (newRole) => {
    setTargetRole(newRole);
    setRolePassword('');
    setRolePasswordError('');
    setShowPassword(false);
    setRoleModalOpen(true);
    setProfileDropdownOpen(false);
  };

  const handleVerifyAndSwitchRole = async (e) => {
    if (e) e.preventDefault();
    if (!rolePassword.trim()) {
      setRolePasswordError('Please enter the password to proceed.');
      return;
    }
    setIsVerifying(true);
    setRolePasswordError('');

    try {
      let isValid = false;
      if (user?.email) {
        const { error } = await supabase.auth.signInWithPassword({
          email: user.email,
          password: rolePassword,
        });
        isValid = !error;
      }

      if (targetRole === 'admin') {
        if (isValid) {
          setActiveRole('admin');
          localStorage.setItem('myfuturepet_active_role', 'admin');
          setRoleModalOpen(false);
        } else {
          setRolePasswordError('Incorrect password for Admin.');
        }
      } else if (targetRole === 'shelter_staff') {
        if (isValid) {
          setActiveRole('shelter_staff');
          localStorage.setItem('myfuturepet_active_role', 'shelter_staff');
          // If the current tab belongs to Admin System groups, redirect to Dashboard
          const systemTabs = ['logs', 'users'];
          if (systemTabs.includes(activeTab)) {
            setActiveTab('analytics');
          }
          setRoleModalOpen(false);
        } else {
          setRolePasswordError('Incorrect password for Shelter Staff.');
        }
      }
    } catch (err) {
      setRolePasswordError('Verification failed. Please check credentials and try again.');
    } finally {
      setIsVerifying(false);
    }
  };

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (sidebarRef.current && !sidebarRef.current.contains(event.target) && sidebarOpen) {
        closeSidebar();
      }
      if (profileRef.current && !profileRef.current.contains(event.target)) {
        setProfileDropdownOpen(false);
      }
    };
    const handleEscape = (event) => {
      if (event.key === 'Escape') {
        closeSidebar();
        setProfileDropdownOpen(false);
        if (!isVerifying) setRoleModalOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('keydown', handleEscape);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('keydown', handleEscape);
    };
  }, [sidebarOpen, isVerifying]);

  // Fetch live counts for badges
  useEffect(() => {
    const fetchBadgeCounts = async () => {
      try {
        const [
          { count: usersCount },
          { count: petsCount },
          { count: pendingAppsCount },
          { count: pendingApptsCount },
        ] = await Promise.all([
          supabase.from('profiles').select('id', { count: 'exact', head: true }),
          supabase.from('pets').select('*', { count: 'exact', head: true }).eq('status', 'available'),
          supabase.from('adoption_applications').select('*', { count: 'exact', head: true }).in('status', ['pending', 'under_review']),
          supabase.from('appointments').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
        ]);

        setBadgeCounts({
          users: usersCount || 0,
          pets: petsCount || 0,
          pendingAdoptions: pendingAppsCount || 0,
          appointments: pendingApptsCount || 0,
        });
      } catch (err) {
        console.warn('Error fetching badge counts:', err);
      }
    };

    fetchBadgeCounts();
  }, [activeTab]);

  const handleSelectTab = (id) => {
    setActiveTab(id);
    closeSidebar();
    setProfileDropdownOpen(false);
  };

  const menuGroups = useMemo(() => [
    {
      header: 'Management',
      items: [
        { id: 'analytics', label: 'Dashboard', icon: FiBarChart2 },
        { id: 'pets', label: 'Pet records', icon: MdPets, badge: badgeCounts.pets },
        { id: 'adoptions', label: 'Adoption reviews', icon: FiClipboard, badge: badgeCounts.pendingAdoptions, alertBadge: badgeCounts.pendingAdoptions > 0 },
        { id: 'appointments', label: 'Appointments', icon: FiCalendar, badge: badgeCounts.appointments, alertBadge: badgeCounts.appointments > 0 },
        { id: 'posts', label: 'Community Posts', icon: FiMessageSquare },
        { id: 'reports', label: 'Reports', icon: FiFileText },
        { id: 'notifications', label: 'Notifications', icon: FiBell },
      ],
    },
    {
      header: 'System',
      items: [
        { id: 'users', label: 'People & access', icon: FiUsers, badge: badgeCounts.users },
        { id: 'logs', label: 'System Logs', icon: FiActivity },
      ],
    },
  ], [badgeCounts]);

  const visibleMenuGroups = useMemo(() => {
    if (activeRole === 'shelter_staff') {
      return menuGroups.filter((g) => g.header === 'Management');
    }
    return menuGroups;
  }, [menuGroups, activeRole]);

  const currentItemInfo = useMemo(() => {
    for (const group of visibleMenuGroups) {
      const found = group.items.find((i) => i.id === activeTab);
      if (found) return { group: group.header, item: found };
    }
    return { group: 'Management', item: { label: 'Dashboard' } };
  }, [activeTab, visibleMenuGroups]);

  const renderContent = () => {
    switch (activeTab) {
      case 'pets':
        return <PetManagement />;
      case 'adoptions':
        return <AdoptionMonitoring />;
      case 'appointments':
        return <AppointmentManagement />;
      case 'users':
        return <UserManagement />;
      case 'posts':
        return <CommunityPosts />;
      case 'reports':
        return <Reports />;
      case 'notifications':
        return <Notifications />;
      case 'logs':
        return <SystemLogs />;
      case 'analytics':
      default:
        return <DashboardOverview onNavigate={handleSelectTab} />;
    }
  };

  const displayName = user?.user_metadata?.name || 'Admin';
  const displayEmail = user?.email || 'admin@myfuturepet.org';

  return (
    <div className={`dashboard-container ${sidebarCollapsed ? 'sidebar-collapsed' : ''}`}>
      {/* Off-canvas backdrop (mobile/tablet) */}
      <div
        className={`sidebar-backdrop ${sidebarOpen ? 'active' : ''}`}
        onClick={closeSidebar}
        aria-hidden="true"
      />

      <aside id="workspace-navigation" className={`sidebar ${sidebarOpen ? 'open' : ''}`} ref={sidebarRef}>
        <div className="sidebar-logo">
          <img src={appLogo} alt="My Future Pet Logo" className="sidebar-app-logo" />
          <div className="logo-text-wrap">
            <span className="logo-text">My Future Pet</span>
            <span className="logo-subtext">Admin Portal</span>
          </div>
          <button
            className="sidebar-close-btn"
            onClick={closeSidebar}
            aria-label="Close sidebar"
          >
            <FiX />
          </button>
        </div>

        <nav className="sidebar-nav">
          {visibleMenuGroups.map((group) => (
            <div className="nav-group" key={group.header}>
              <span className="nav-header">{group.header}</span>
              {group.items.map((item) => {
                const Icon = item.icon;
                const isActive = activeTab === item.id;
                return (
                  <button
                    key={item.id}
                    className={`menu-item ${isActive ? 'active' : ''}`}
                    onClick={() => handleSelectTab(item.id)}
                    title={sidebarCollapsed ? item.label : ''}
                    aria-label={item.label}
                    aria-current={isActive ? 'page' : undefined}
                  >
                    <Icon className="menu-icon" />
                    <span className="menu-label">{item.label}</span>
                    {item.badge != null && item.badge > 0 && !sidebarCollapsed && (
                      <span className={`sidebar-badge ${item.alertBadge ? 'alert-pill' : ''}`}>
                        {item.badge}
                      </span>
                    )}
                  </button>
                );
              })}
            </div>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="version">Jagna shelter workspace</div>
          <div className="copyright">© 2026 My Future Pet</div>
        </div>

        <button
          className="collapse-toggle"
          onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
          title={sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          aria-label={sidebarCollapsed ? 'Expand sidebar' : 'Collapse sidebar'}
          aria-expanded={!sidebarCollapsed}
        >
          <FiMenu className="collapse-icon" />
        </button>
      </aside>

      <main className="main-area">
        <header className="topbar">
          <button
            className="hamburger-btn"
            onClick={() => setSidebarOpen(true)}
            aria-label="Open menu"
            aria-expanded={sidebarOpen}
            aria-controls="workspace-navigation"
          >
            <FiMenu />
          </button>

          <div className="greeting">
            {activeTab === 'analytics' ? (
              <>
                <h1>Shelter overview</h1>
                <p>
                  {activeRole === 'shelter_staff'
                    ? 'Rescue operations & shelter management for Jagna Animal Lover and Rescue Group.'
                    : "Your shelter at a glance. Every record, every next step."}
                </p>
              </>
            ) : (
              <>
                <div className="breadcrumb-trail">
                  <span>{currentItemInfo.group}</span>
                  <span className="breadcrumb-sep">/</span>
                  <span className="breadcrumb-current">{currentItemInfo.item.label}</span>
                </div>
                <h1 className="tab-heading">{currentItemInfo.item.label}</h1>
              </>
            )}
          </div>

          <label className="workspace-jump"><span>Go to</span><select aria-label="Go to workspace section" value={activeTab} onChange={event => handleSelectTab(event.target.value)}>{visibleMenuGroups.flatMap(group => group.items).map(item => <option key={item.id} value={item.id}>{item.label}</option>)}</select></label>

          {/* Topbar Role Switcher Indicator & Quick-Switch */}
          <div className="topbar-role-switcher">
            <div className={`role-pill-badge ${activeRole === 'shelter_staff' ? 'staff-badge' : 'admin-badge'}`}>
              <span className="role-badge-text">
                {activeRole === 'shelter_staff' ? 'Shelter Staff (JALRG)' : 'Admin'}
              </span>
            </div>
            <button
              type="button"
              className="role-switch-pill-btn"
              onClick={() => handleOpenRoleModal(activeRole === 'admin' ? 'shelter_staff' : 'admin')}
              title={activeRole === 'admin' ? 'Switch to Shelter Staff view' : 'Switch to Admin view'}
            >
              <FiRepeat className="role-switch-icon" />
              <span>{activeRole === 'admin' ? 'Switch to Staff' : 'Switch to Admin'}</span>
            </button>
          </div>

          <div className="profile-area" ref={profileRef}>
            <button
              className="notif-btn"
              title="View Notifications"
              onClick={() => handleSelectTab('notifications')}
            >
              <FiBell />
              {badgeCounts.pendingAdoptions > 0 && <span className="notif-badge" />}
            </button>

            <button
              type="button"
              className="profile-trigger"
              aria-expanded={profileDropdownOpen}
              aria-label="Account options"
              onClick={() => setProfileDropdownOpen(!profileDropdownOpen)}
              title={activeRole === 'shelter_staff' ? 'Shelter Staff Menu' : 'Admin Profile Menu'}
            >
              <div className={`avatar ${activeRole === 'shelter_staff' ? 'staff-avatar' : ''}`}>
                {activeRole === 'shelter_staff' ? 'S' : displayName.charAt(0).toUpperCase()}
              </div>
              <div className="profile-info">
                <span className="profile-name">
                  {activeRole === 'shelter_staff' ? 'Shelter Staff' : displayName}
                </span>
                <span className="profile-title">
                  {activeRole === 'shelter_staff' ? 'Shelter Operations' : 'Admin'}
                </span>
              </div>
              <FiChevronDown className={`dropdown-arrow ${profileDropdownOpen ? 'rotated' : ''}`} />
            </button>

            {/* Profile Dropdown Menu */}
            {profileDropdownOpen && (
              <div className="profile-dropdown-menu">
                <div className="dropdown-user-header">
                  <strong>{activeRole === 'shelter_staff' ? 'Shelter Staff (JALRG)' : displayName}</strong>
                  <span>{displayEmail}</span>
                </div>
                <div className="dropdown-divider" />
                <button type="button" className="dropdown-item logout" onClick={onLogout}>
                  <FiLogOut /> Sign Out
                </button>
              </div>
            )}
          </div>
        </header>

        <div className="content-area">{renderContent()}</div>
      </main>

      {/* Password-Protected Role Switcher Modal */}
      {roleModalOpen && (
        <div
          className="role-modal-overlay"
          onClick={() => !isVerifying && setRoleModalOpen(false)}
        >
          <div
            className="role-modal-dialog"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="role-modal-header">
              <div className={`role-modal-icon-wrap ${targetRole === 'shelter_staff' ? 'staff' : 'admin'}`}>
                {targetRole === 'shelter_staff' ? <FiHome /> : <FiShield />}
              </div>
              <div className="role-modal-header-text">
                <h3>
                  {targetRole === 'shelter_staff'
                    ? 'Switch to Shelter Staff'
                    : 'Switch to Admin'}
                </h3>
                <p>
                  {targetRole === 'shelter_staff'
                    ? 'Enter the Shelter Staff password to access rescue operations and shelter tools.'
                    : 'Enter the Admin password to access system administration and controls.'}
                </p>
              </div>
              <button
                type="button"
                className="role-modal-close"
                onClick={() => !isVerifying && setRoleModalOpen(false)}
                disabled={isVerifying}
                aria-label="Close modal"
              >
                <FiX />
              </button>
            </div>

            <form onSubmit={handleVerifyAndSwitchRole} className="role-modal-body">
              {rolePasswordError && (
                <div className="role-modal-error">
                  <span>{rolePasswordError}</span>
                </div>
              )}

              <div className="role-input-group">
                <label htmlFor="role-password-input">
                  <FiLock className="input-label-icon" />
                  {targetRole === 'shelter_staff' ? 'Shelter Staff Password' : 'Admin Password'}
                </label>
                <div className="role-input-wrap">
                  <input
                    id="role-password-input"
                    type={showPassword ? 'text' : 'password'}
                    placeholder={`Enter ${targetRole === 'shelter_staff' ? 'shelter staff' : 'admin'} password...`}
                    value={rolePassword}
                    onChange={(e) => {
                      setRolePassword(e.target.value);
                      if (rolePasswordError) setRolePasswordError('');
                    }}
                    autoFocus
                    disabled={isVerifying}
                  />
                  <button
                    type="button"
                    className="pw-visibility-toggle"
                    onClick={() => setShowPassword(!showPassword)}
                    tabIndex={-1}
                    title={showPassword ? 'Hide password' : 'Show password'}
                  >
                    {showPassword ? <FiEyeOff /> : <FiEye />}
                  </button>
                </div>
              </div>

              <p className="text-xs text-slate-500">Enter your own account password to switch roles.</p>

              <div className="role-modal-actions">
                <button
                  type="button"
                  className="role-cancel-btn"
                  onClick={() => setRoleModalOpen(false)}
                  disabled={isVerifying}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className={`role-confirm-btn ${targetRole === 'shelter_staff' ? 'staff' : 'admin'}`}
                  disabled={isVerifying}
                >
                  {isVerifying ? (
                    'Verifying...'
                  ) : (
                    <>
                      <FiUserCheck /> Verify &amp; Switch
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default DashboardPage;