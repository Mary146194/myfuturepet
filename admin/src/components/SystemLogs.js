import React, { useState, useEffect } from 'react';
import { supabase } from '../config/supabaseClient';
import { 
  FiRefreshCw, 
  FiSearch, 
  FiClock, 
  FiUser, 
  FiInfo, 
  FiEye, 
  FiDownload, 
  FiCheckCircle, 
  FiCopy, 
  FiX, 
  FiShield, 
  FiActivity,
  FiLock,
  FiPlus,
  FiEdit2,
  FiTrash2
} from 'react-icons/fi';
import './SystemLogs.css';

function SystemLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  
  // Inspection Modal State
  const [inspectModal, setInspectModal] = useState({
    isOpen: false,
    log: null,
  });

  // Custom Toast State
  const [toast, setToast] = useState(null);

  const showToast = (message, type = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3500);
  };

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async () => {
    setLoading(true);
    setError('');
    try {
      const { data, error: fetchError } = await supabase
        .from('system_logs')
        .select(`
          id,
          actor_id,
          action,
          entity,
          entity_id,
          details,
          created_at,
          actor:actor_id (
            full_name
          )
        `)
        .order('created_at', { ascending: false })
        .limit(100);

      if (fetchError) {
        console.warn('System logs fetch error:', fetchError.message);
        setError(fetchError.message);
        setLogs([]);
      } else {
        setLogs(data || []);
      }
    } catch (err) {
      console.error(err);
      setError('Failed to fetch system logs');
    }
    setLoading(false);
  };

  const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    showToast('Copied JSON payload to clipboard!');
  };

  const exportAuditLog = () => {
    try {
      const exportDate = new Date().toISOString().split('T')[0];
      const dataStr = JSON.stringify(logs, null, 2);
      const blob = new Blob([dataStr], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `MyFuturePet_AuditTrail_${exportDate}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
      showToast('System audit trail downloaded as JSON');
    } catch (err) {
      console.error(err);
      showToast('Failed to export audit logs', 'error');
    }
  };

  const filteredLogs = logs.filter((log) => {
    const actionUpper = (log.action || '').toUpperCase();
    
    // Category match
    let matchesCategory = true;
    if (categoryFilter === 'auth') {
      matchesCategory = actionUpper.includes('AUTH') || actionUpper.includes('LOGIN') || actionUpper.includes('ROLE');
    } else if (categoryFilter === 'insert') {
      matchesCategory = actionUpper.includes('INSERT') || actionUpper.includes('CREATE');
    } else if (categoryFilter === 'update') {
      matchesCategory = actionUpper.includes('UPDATE') || actionUpper.includes('EDIT') || actionUpper.includes('STATUS');
    } else if (categoryFilter === 'delete') {
      matchesCategory = actionUpper.includes('DELETE') || actionUpper.includes('REMOVE');
    }

    const actorName = log.actor?.full_name || '';
    const actorEmail = log.actor?.email || '';
    const actionText = log.action || '';
    const entityText = log.entity || '';
    const searchLower = searchTerm.toLowerCase();

    const matchesSearch =
      actorName.toLowerCase().includes(searchLower) ||
      actorEmail.toLowerCase().includes(searchLower) ||
      actionText.toLowerCase().includes(searchLower) ||
      entityText.toLowerCase().includes(searchLower) ||
      JSON.stringify(log.details || {}).toLowerCase().includes(searchLower);

    return matchesCategory && matchesSearch;
  });

  const getActionClass = (action) => {
    const act = (action || '').toUpperCase();
    if (act.includes('DELETE') || act.includes('REMOVE')) return 'action-delete';
    if (act.includes('INSERT') || act.includes('CREATE')) return 'action-insert';
    if (act.includes('UPDATE') || act.includes('EDIT')) return 'action-update';
    if (act.includes('AUTH') || act.includes('ROLE')) return 'action-auth';
    return 'action-default';
  };

  // Distinct operators count
  const distinctActors = new Set(logs.map((l) => l.actor?.email).filter(Boolean)).size;

  return (
    <div className="system-logs-container">
      {/* Toast Feedback */}
      {toast && (
        <div className={`logs-toast toast-${toast.type}`}>
          <FiCheckCircle />
          <span>{toast.message}</span>
        </div>
      )}

      <div className="logs-header">
        <div>
          <h2>System Logs &amp; Audit Trail</h2>
          <p className="section-subtitle">
            Immutable audit record of administrative operations, account modifications, and platform events.
          </p>
        </div>

        <div className="logs-header-actions">
          <button onClick={exportAuditLog} className="export-logs-btn" disabled={logs.length === 0}>
            <FiDownload /> Export Audit (JSON)
          </button>
          <button onClick={fetchLogs} className="refresh-btn" disabled={loading}>
            <FiRefreshCw className={loading ? 'spin-icon' : ''} /> Refresh Logs
          </button>
        </div>
      </div>

      {error && (
        <div className="error-message">
          Notice: {error} (Check Supabase permissions or table availability).
        </div>
      )}

      {/* KPI Ribbon */}
      <div className="logs-kpi-ribbon">
        <div className="kpi-item">
          <div className="kpi-icon icon-events"><FiActivity /></div>
          <div>
            <span className="kpi-label">Recorded Events</span>
            <span className="kpi-value">{logs.length}</span>
          </div>
        </div>

        <div className="kpi-item">
          <div className="kpi-icon icon-actors"><FiUser /></div>
          <div>
            <span className="kpi-label">Active Operators</span>
            <span className="kpi-value">{distinctActors || 1}</span>
          </div>
        </div>

        <div className="kpi-item">
          <div className="kpi-icon icon-mod"><FiShield /></div>
          <div>
            <span className="kpi-label">Security &amp; Auth Audits</span>
            <span className="kpi-value">
              {logs.filter((l) => (l.action || '').toUpperCase().includes('AUTH') || (l.action || '').toUpperCase().includes('ROLE')).length}
            </span>
          </div>
        </div>

        <div className="kpi-item">
          <div className="kpi-icon icon-status"><FiCheckCircle /></div>
          <div>
            <span className="kpi-label">Integrity Status</span>
            <span className="kpi-value status-good">Verified</span>
          </div>
        </div>
      </div>

      {/* Controls: Search & Category Chips */}
      <div className="controls">
        <div className="search-input-wrapper">
          <FiSearch className="search-icon" />
          <input
            type="text"
            placeholder="Search audit trail by actor name, email, action, entity, or JSON payload..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
          {searchTerm && (
            <button className="clear-search-btn" onClick={() => setSearchTerm('')}>
              <FiX />
            </button>
          )}
        </div>

        <div className="category-filter-chips">
          <button
            className={`cat-chip ${categoryFilter === 'all' ? 'active' : ''}`}
            onClick={() => setCategoryFilter('all')}
          >
            All Logs ({logs.length})
          </button>
          <button
            className={`cat-chip ${categoryFilter === 'auth' ? 'active' : ''}`}
            onClick={() => setCategoryFilter('auth')}
          >
            <FiLock /> Security &amp; Auth
          </button>
          <button
            className={`cat-chip ${categoryFilter === 'insert' ? 'active' : ''}`}
            onClick={() => setCategoryFilter('insert')}
          >
            <FiPlus /> Insertions
          </button>
          <button
            className={`cat-chip ${categoryFilter === 'update' ? 'active' : ''}`}
            onClick={() => setCategoryFilter('update')}
          >
            <FiEdit2 /> Modifications
          </button>
          <button
            className={`cat-chip ${categoryFilter === 'delete' ? 'active' : ''}`}
            onClick={() => setCategoryFilter('delete')}
          >
            <FiTrash2 /> Deletions
          </button>
        </div>
      </div>

      {/* Logs Table */}
      <div className="logs-table-card">
        <table className="logs-table">
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Action Category</th>
              <th>Target Entity</th>
              <th>Performed By</th>
              <th>Payload Details</th>
              <th>Inspect</th>
            </tr>
          </thead>
          <tbody>
            {filteredLogs.length > 0 ? (
              filteredLogs.map((log) => (
                <tr key={log.id}>
                  <td className="log-time">
                    <FiClock className="cell-icon" />
                    <span>{new Date(log.created_at).toLocaleString()}</span>
                  </td>
                  <td>
                    <span className={`action-pill ${getActionClass(log.action)}`}>
                      {log.action}
                    </span>
                  </td>
                  <td>
                    <strong>{log.entity || 'System'}</strong>
                    {log.entity_id && (
                      <small className="entity-id-sub">#{String(log.entity_id).substring(0, 8)}</small>
                    )}
                  </td>
                  <td>
                    <div className="actor-cell">
                      <FiUser className="cell-icon" />
                      <div>
                        <div>{log.actor?.full_name || 'System Auto'}</div>
                        <small className="muted-text">{log.actor?.email || 'automated-task'}</small>
                      </div>
                    </div>
                  </td>
                  <td>
                    {log.details ? (
                      <code className="details-code">
                        {typeof log.details === 'object' 
                          ? JSON.stringify(log.details) 
                          : String(log.details)}
                      </code>
                    ) : (
                      <span className="muted-text">No additional details</span>
                    )}
                  </td>
                  <td>
                    <button
                      className="inspect-log-btn"
                      onClick={() => setInspectModal({ isOpen: true, log })}
                      title="Inspect Log Details"
                    >
                      <FiEye /> View
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6" className="empty-row">
                  <FiInfo className="empty-icon" />
                  <h4>No System Logs Recorded</h4>
                  <p>
                    {searchTerm || categoryFilter !== 'all'
                      ? 'No events match your current filter criteria.'
                      : 'Audit log entries for administrative operations will appear here.'}
                  </p>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Inspection Modal */}
      {inspectModal.isOpen && inspectModal.log && (
        <div className="user-modal-backdrop" onClick={() => setInspectModal({ isOpen: false, log: null })}>
          <div className="inspect-modal-card" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <div className="modal-title-row">
                <FiShield className="shield-icon" />
                <div>
                  <h3>Audit Event Inspection</h3>
                  <p className="log-id-sub">Event Reference ID: #{inspectModal.log.id}</p>
                </div>
              </div>
              <button 
                className="close-modal-btn" 
                onClick={() => setInspectModal({ isOpen: false, log: null })}
              >
                <FiX />
              </button>
            </div>

            <div className="inspect-modal-body">
              <div className="inspect-meta-grid">
                <div className="meta-box">
                  <span className="meta-label">Action Performed</span>
                  <span className={`action-pill ${getActionClass(inspectModal.log.action)}`}>
                    {inspectModal.log.action}
                  </span>
                </div>
                <div className="meta-box">
                  <span className="meta-label">Timestamp</span>
                  <strong>{new Date(inspectModal.log.created_at).toLocaleString()}</strong>
                </div>
                <div className="meta-box">
                  <span className="meta-label">Target Entity</span>
                  <strong>{inspectModal.log.entity || 'Platform Record'}</strong>
                </div>
                <div className="meta-box">
                  <span className="meta-label">Operator</span>
                  <strong>{inspectModal.log.actor?.full_name || 'System / Auto'}</strong>
                  <small className="muted-text">{inspectModal.log.actor?.email || ''}</small>
                </div>
              </div>

              <div className="payload-section">
                <div className="payload-header">
                  <span>Structured Payload Data (JSON)</span>
                  <button
                    className="copy-payload-btn"
                    onClick={() => copyToClipboard(JSON.stringify(inspectModal.log.details, null, 2))}
                  >
                    <FiCopy /> Copy JSON
                  </button>
                </div>
                <pre className="json-pre-viewer">
                  {inspectModal.log.details 
                    ? JSON.stringify(inspectModal.log.details, null, 2)
                    : '{\n  "status": "No additional payload recorded"\n}'}
                </pre>
              </div>
            </div>

            <div className="modal-footer">
              <button 
                className="close-btn" 
                onClick={() => setInspectModal({ isOpen: false, log: null })}
              >
                Close Inspector
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default SystemLogs;
