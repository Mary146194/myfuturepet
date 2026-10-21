import React from 'react';
import { FiArrowLeft } from 'react-icons/fi';
import './PagePlaceholder.css';

function PagePlaceholder({ icon: IconComponent, title, description }) {
  return (
    <div className="page-placeholder">
      <div className="placeholder-card">
        <div className="placeholder-icon">
          <IconComponent />
        </div>
        <h2>{title}</h2>
        <p>{description}</p>
        <div className="placeholder-coming">
          <span className="placeholder-pill">Coming Soon</span>
        </div>
        <button className="back-btn" onClick={() => window.history.back()}>
          <FiArrowLeft /> Back to Dashboard
        </button>
      </div>
    </div>
  );
}

export default PagePlaceholder;