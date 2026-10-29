import React, { useState, useEffect } from 'react';
import { supabase } from '../config/supabaseClient';
import { 
  FiRefreshCw, 
  FiUsers, 
  FiMessageSquare, 
  FiDownload, 
  FiCheckCircle, 
  FiClock, 
  FiTrendingUp,
  FiFilter,
  FiPrinter,
  FiFileText,
  FiList
} from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import './Reports.css';

function Reports() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalPets: 0,
    availablePets: 0,
    adoptedPets: 0,
    totalApplications: 0,
    pendingApps: 0,
    underReviewApps: 0,
    approvedApps: 0,
    rejectedApps: 0,
    totalPosts: 0,
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [exporting, setExporting] = useState(false);
  const [toast, setToast] = useState(null);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3800);
  };

  const downloadCsv = (content, filename) => {
    const blob = new Blob([content], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  useEffect(() => {
    fetchReports();
  }, []);

  const fetchReports = async () => {
    setLoading(true);
    setError('');
    try {
      // Fetch users count
      const { count: usersCount } = await supabase
        .from('profiles')
        .select('id', { count: 'exact', head: true });

      // Fetch pets data
      const { data: petsData } = await supabase
        .from('pets')
        .select('status');

      // Fetch adoption applications
      const { data: appsData } = await supabase
        .from('adoption_applications')
        .select('status');

      // Fetch community posts
      const { count: postsCount } = await supabase
        .from('community_posts')
        .select('*', { count: 'exact', head: true });

      const petCounts = petsData?.reduce((acc, p) => {
        if (p.status === 'available') acc.available++;
        if (p.status === 'adopted') acc.adopted++;
        return acc;
      }, { available: 0, adopted: 0 }) || { available: 0, adopted: 0 };

      const appCounts = appsData?.reduce((acc, a) => {
        if (a.status === 'pending') acc.pending++;
        if (a.status === 'under_review') acc.under_review++;
        if (a.status === 'approved') acc.approved++;
        if (a.status === 'rejected') acc.rejected++;
        return acc;
      }, { pending: 0, under_review: 0, approved: 0, rejected: 0 }) || { pending: 0, under_review: 0, approved: 0, rejected: 0 };

      setStats({
        totalUsers: usersCount || 0,
        totalPets: petsData?.length || 0,
        availablePets: petCounts.available,
        adoptedPets: petCounts.adopted,
        totalApplications: appsData?.length || 0,
        pendingApps: appCounts.pending,
        underReviewApps: appCounts.under_review,
        approvedApps: appCounts.approved,
        rejectedApps: appCounts.rejected,
        totalPosts: postsCount || 0,
      });
    } catch (err) {
      setError('Failed to fetch platform reports');
      console.error(err);
    }
    setLoading(false);
  };

  const exportReportCSV = () => {
    setExporting(true);
    try {
      const reportDate = new Date().toISOString().split('T')[0];
      const csvRows = [
        ['MY FUTURE PET - SYSTEM RECORDS & ANALYTICS REPORT'],
        ['Generated On', new Date().toLocaleString()],
        ['Partner Organization', 'Jagna Animal Lover & Rescue Group (JALRG)'],
        ['Project Scope', 'Non-commercial Mobile AR Pet Adoption System'],
        [],
        ['Metric Category', 'Metric Name', 'Value'],
        ['Users', 'Total Registered Profiles', stats.totalUsers],
        ['Rescue Shelter', 'Operating Shelter Partner', 'JALRG (Jagna, Bohol)'],
        ['Pets', 'Total Pet Listings', stats.totalPets],
        ['Pets', 'Available for Adoption', stats.availablePets],
        ['Pets', 'Successfully Adopted', stats.adoptedPets],
        ['Adoptions', 'Total Screening Applications', stats.totalApplications],
        ['Adoptions', 'Pending Review', stats.pendingApps],
        ['Adoptions', 'Under Active Review', stats.underReviewApps],
        ['Adoptions', 'Approved Applications', stats.approvedApps],
        ['Adoptions', 'Rejected Applications', stats.rejectedApps],
        ['Community', 'Total Community Feed Posts', stats.totalPosts],
        ['Performance', 'Adoption Placement Ratio', `${stats.totalPets > 0 ? Math.round((stats.adoptedPets / stats.totalPets) * 100) : 0}%`],
        ['Performance', 'Application Approval Rate', `${stats.totalApplications > 0 ? Math.round((stats.approvedApps / stats.totalApplications) * 100) : 0}%`],
      ];

      const csvContent = '\uFEFF' + csvRows.map((e) => e.join(',')).join('\n');
      downloadCsv(csvContent, `MyFuturePet_Analytics_${reportDate}.csv`);

      showToast('Analytics summary exported as CSV successfully');
    } catch (err) {
      console.error(err);
      showToast('Failed to generate CSV export', 'error');
    }
    setExporting(false);
  };

  const exportApplicationsCSV = async () => {
    setExporting(true);
    try {
      const { data, error } = await supabase
        .from('adoption_applications')
        .select(`
          id,
          full_name,
          contact_number,
          address,
          housing_type,
          status,
          review_notes,
          created_at,
          decided_at,
          pet:pet_id (name, type, breed)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;

      const reportDate = new Date().toISOString().split('T')[0];
      const headers = ['Application ID', 'Applicant Name', 'Contact Number', 'Address', 'Housing Type', 'Pet Name', 'Pet Breed', 'Status', 'Review Remarks', 'Submission Date', 'Decision Date'];
      const rows = (data || []).map((app) => [
        app.id,
        `"${(app.full_name || '').replace(/"/g, '""')}"`,
        `"${(app.contact_number || '').replace(/"/g, '""')}"`,
        `"${(app.address || '').replace(/"/g, '""')}"`,
        app.housing_type || '',
        `"${(app.pet?.name || '').replace(/"/g, '""')}"`,
        `"${(app.pet?.breed || '').replace(/"/g, '""')}"`,
        app.status || '',
        `"${(app.review_notes || '').replace(/"/g, '""')}"`,
        app.created_at ? new Date(app.created_at).toLocaleDateString() : '',
        app.decided_at ? new Date(app.decided_at).toLocaleDateString() : 'Pending',
      ]);

      const csvContent = '\uFEFF' + [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
      downloadCsv(csvContent, `MyFuturePet_Applications_${reportDate}.csv`);

      showToast('Applications ledger exported to CSV successfully');
    } catch (err) {
      console.error(err);
      showToast('Failed to export applications: ' + err.message, 'error');
    }
    setExporting(false);
  };

  const exportPetsInventoryCSV = async () => {
    setExporting(true);
    try {
      const { data, error } = await supabase
        .from('pets')
        .select('id, name, type, breed, age, gender, status, size, created_at')
        .order('name');

      if (error) throw error;

      const reportDate = new Date().toISOString().split('T')[0];
      const headers = ['Pet ID', 'Name', 'Category', 'Breed', 'Age', 'Gender', 'Size', 'Adoption Status', 'Registration Date'];
      const rows = (data || []).map((p) => [
        p.id,
        `"${(p.name || '').replace(/"/g, '""')}"`,
        p.type || '',
        `"${(p.breed || '').replace(/"/g, '""')}"`,
        p.age || '',
        p.gender || '',
        p.size || '',
        p.status || '',
        p.created_at ? new Date(p.created_at).toLocaleDateString() : '',
      ]);

      const csvContent = '\uFEFF' + [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
      downloadCsv(csvContent, `MyFuturePet_Pet_Inventory_${reportDate}.csv`);

      showToast('Pet inventory exported to CSV successfully');
    } catch (err) {
      console.error(err);
      showToast('Failed to export pet inventory: ' + err.message, 'error');
    }
    setExporting(false);
  };

  const handlePrint = () => {
    window.print();
  };

  // Distribution calculations
  const availablePct = stats.totalPets > 0 ? Math.round((stats.availablePets / stats.totalPets) * 100) : 0;
  const adoptedPct = stats.totalPets > 0 ? Math.round((stats.adoptedPets / stats.totalPets) * 100) : 0;

  const pendingPct = stats.totalApplications > 0 ? Math.round((stats.pendingApps / stats.totalApplications) * 100) : 0;
  const reviewPct = stats.totalApplications > 0 ? Math.round((stats.underReviewApps / stats.totalApplications) * 100) : 0;
  const approvedPct = stats.totalApplications > 0 ? Math.round((stats.approvedApps / stats.totalApplications) * 100) : 0;
  const rejectedPct = stats.totalApplications > 0 ? Math.round((stats.rejectedApps / stats.totalApplications) * 100) : 0;

  return (
    <div className="reports">
      {/* Toast Notification */}
      {toast && (
        <div className={`reports-toast toast-${toast.type}`}>
          <FiCheckCircle />
          <span>{toast.message}</span>
        </div>
      )}

      <div className="reports-header-area">
        <div>
          <p className="section-subtitle">
            Comprehensive platform records, adoption metrics, and analytical summaries for Jagna Animal Lover & Rescue Group.
          </p>
        </div>

        <div className="reports-header-actions">
          <button onClick={fetchReports} className="refresh-btn" disabled={loading} title="Reload latest data">
            <FiRefreshCw className={loading ? 'spin-icon' : ''} /> Refresh
          </button>
          <button onClick={exportReportCSV} className="export-csv-btn" disabled={exporting || loading} title="Export summary statistics to CSV">
            <FiDownload /> Summary CSV
          </button>
          <button onClick={exportApplicationsCSV} className="export-csv-btn export-apps-btn" disabled={exporting || loading} title="Export detailed applications ledger to CSV">
            <FiFileText /> Applications CSV
          </button>
          <button onClick={exportPetsInventoryCSV} className="export-csv-btn export-pets-btn" disabled={exporting || loading} title="Export pet inventory to CSV">
            <FiList /> Pet Roster CSV
          </button>
          <button onClick={handlePrint} className="print-btn" title="Print or save report as PDF">
            <FiPrinter /> Print / PDF
          </button>
        </div>
      </div>

      {error && <div className="error-message">{error}</div>}

      {/* Primary KPI Grid */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon-badge icon-users">
            <FiUsers />
          </div>
          <div className="stat-card-details">
            <span className="stat-label">Registered Accounts</span>
            <h3 className="stat-number">{stats.totalUsers}</h3>
            <p className="stat-subtext">Verified adopters &amp; shelter staff</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon-badge icon-pets">
            <MdPets />
          </div>
          <div className="stat-card-details">
            <span className="stat-label">Total Rescued Pets</span>
            <h3 className="stat-number">{stats.totalPets}</h3>
            <p className="stat-subtext">
              <strong className="text-green">{stats.availablePets}</strong> available • <strong className="text-blue">{stats.adoptedPets}</strong> adopted
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon-badge icon-apps">
            <FiCheckCircle />
          </div>
          <div className="stat-card-details">
            <span className="stat-label">Screening Applications</span>
            <h3 className="stat-number">{stats.totalApplications}</h3>
            <p className="stat-subtext">
              <strong className="text-green">{stats.approvedApps}</strong> approved • <strong className="text-red">{stats.rejectedApps}</strong> rejected
            </p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon-badge icon-pending">
            <FiClock />
          </div>
          <div className="stat-card-details">
            <span className="stat-label">Active Queue</span>
            <h3 className="stat-number">{stats.pendingApps + stats.underReviewApps}</h3>
            <p className="stat-subtext">{stats.underReviewApps} under active staff review</p>
          </div>
        </div>

        <div className="stat-card">
          <div className="stat-icon-badge icon-posts">
            <FiMessageSquare />
          </div>
          <div className="stat-card-details">
            <span className="stat-label">Community Stories</span>
            <h3 className="stat-number">{stats.totalPosts}</h3>
            <p className="stat-subtext">Feed updates &amp; announcements</p>
          </div>
        </div>
      </div>

      {/* Visual Distribution & Funnel Analysis Section */}
      <div className="visual-reports-container">
        {/* Card 1: Pet Placement Distribution */}
        <div className="visual-card">
          <div className="card-top">
            <div>
              <h4><MdPets style={{ marginRight: '6px', verticalAlign: 'middle' }} /> Pet Placement Distribution</h4>
              <p>Proportion of available rescued pets vs successfully adopted</p>
            </div>
            <span className="ratio-highlight">{adoptedPct}% Placed</span>
          </div>

          <div className="multi-ratio-bar">
            <div 
              className="ratio-segment segment-available" 
              style={{ width: `${stats.totalPets > 0 ? (stats.availablePets / stats.totalPets) * 100 : 50}%` }}
              title={`Available: ${stats.availablePets} (${availablePct}%)`}
            />
            <div 
              className="ratio-segment segment-adopted" 
              style={{ width: `${stats.totalPets > 0 ? (stats.adoptedPets / stats.totalPets) * 100 : 50}%` }}
              title={`Adopted: ${stats.adoptedPets} (${adoptedPct}%)`}
            />
          </div>

          <div className="ratio-legend">
            <div className="legend-item">
              <span className="legend-dot dot-available" />
              <span>Available for Adoption: <strong>{stats.availablePets} ({availablePct}%)</strong></span>
            </div>
            <div className="legend-item">
              <span className="legend-dot dot-adopted" />
              <span>Successfully Adopted: <strong>{stats.adoptedPets} ({adoptedPct}%)</strong></span>
            </div>
          </div>
        </div>

        {/* Card 2: Adoption Screening Pipeline Funnel */}
        <div className="visual-card">
          <div className="card-top">
            <div>
              <h4><FiFilter style={{ marginRight: '6px', verticalAlign: 'middle' }} /> Adoption Screening Funnel</h4>
              <p>Stage breakdown across all submitted applicant dossiers</p>
            </div>
            <span className="ratio-highlight">{approvedPct}% Approval Rate</span>
          </div>

          <div className="multi-ratio-bar">
            <div 
              className="ratio-segment segment-pending" 
              style={{ width: `${pendingPct || 0}%` }}
              title={`Pending: ${stats.pendingApps} (${pendingPct}%)`}
            />
            <div 
              className="ratio-segment segment-review" 
              style={{ width: `${reviewPct || 0}%` }}
              title={`Under Review: ${stats.underReviewApps} (${reviewPct}%)`}
            />
            <div 
              className="ratio-segment segment-approved" 
              style={{ width: `${approvedPct || 0}%` }}
              title={`Approved: ${stats.approvedApps} (${approvedPct}%)`}
            />
            <div 
              className="ratio-segment segment-rejected" 
              style={{ width: `${rejectedPct || 0}%` }}
              title={`Rejected: ${stats.rejectedApps} (${rejectedPct}%)`}
            />
          </div>

          <div className="ratio-legend funnel-legend">
            <div className="legend-item">
              <span className="legend-dot dot-pending" />
              <span>Pending: <strong>{stats.pendingApps}</strong> ({pendingPct}%)</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot dot-review" />
              <span>In Review: <strong>{stats.underReviewApps}</strong> ({reviewPct}%)</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot dot-approved" />
              <span>Approved: <strong>{stats.approvedApps}</strong> ({approvedPct}%)</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot dot-rejected" />
              <span>Rejected: <strong>{stats.rejectedApps}</strong> ({rejectedPct}%)</span>
            </div>
          </div>
        </div>
      </div>

      {/* Key Performance Indicators Summary Cards */}
      <div className="records-section">
        <div className="records-header">
          <h3>Platform Health &amp; Operational Efficiency</h3>
          <p className="records-sub">Calculated real-time operational indices for shelter management</p>
        </div>

        <div className="metrics-container">
          <div className="metric-item">
            <div className="metric-icon-badge">
              <FiCheckCircle />
            </div>
            <div className="metric-info">
              <label>Adoption Approval Rate</label>
              <div className="metric-value">
                {stats.totalApplications > 0 
                  ? Math.round((stats.approvedApps / stats.totalApplications) * 100) 
                  : 0}%
              </div>
              <small>Percentage of reviewed applications granted</small>
            </div>
          </div>

          <div className="metric-item">
            <div className="metric-icon-badge">
              <MdPets />
            </div>
            <div className="metric-info">
              <label>Pet Placement Ratio</label>
              <div className="metric-value">
                {stats.totalPets > 0 
                  ? Math.round((stats.adoptedPets / stats.totalPets) * 100) 
                  : 0}%
              </div>
              <small>Ratio of listed pets successfully homed</small>
            </div>
          </div>

          <div className="metric-item">
            <div className="metric-icon-badge">
              <FiTrendingUp />
            </div>
            <div className="metric-info">
              <label>Avg. Applications Per Pet</label>
              <div className="metric-value">
                {stats.totalPets > 0 
                  ? (stats.totalApplications / stats.totalPets).toFixed(2)
                  : '0.00'}
              </div>
              <small>Interest density across listed rescues</small>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Reports;
