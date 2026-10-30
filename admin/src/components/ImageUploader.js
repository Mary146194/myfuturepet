import React, { useState, useRef } from 'react';
import {
  FiUploadCloud, FiLink, FiCheckCircle,
  FiTrash2, FiAlertCircle, FiRefreshCw, FiZap
} from 'react-icons/fi';
import { compressImage, formatBytes } from '../utils/imageCompressor';
import { uploadPetImage } from '../services/imageUploadService';
import './ImageUploader.css';

export default function ImageUploader({
  currentUrl,
  onChange,
  petName = 'Pet',
  petType = 'dog',
}) {
  const [activeTab, setActiveTab] = useState(currentUrl ? 'url' : 'file'); // 'file' | 'url'
  const [isDragging, setIsDragging] = useState(false);
  const [isProcessing, setIsProcessing] = useState(false);
  const [compressionStats, setCompressionStats] = useState(null);
  const [errorMessage, setErrorMessage] = useState('');
  const [uploadSuccess, setUploadSuccess] = useState(false);
  const [providerUsed, setProviderUsed] = useState('');
  const fileInputRef = useRef(null);

  const handleFileSelected = async (file) => {
    if (!file) return;
    if (!file.type.startsWith('image/')) {
      setErrorMessage('Please select a valid image file (JPG, PNG, WebP).');
      return;
    }

    setErrorMessage('');
    setIsProcessing(true);
    setUploadSuccess(false);

    try {
      // 1. Client-side Image Compression (Reduces 4-8 MB to ~100 KB)
      const compressed = await compressImage(file, {
        maxWidth: 1000,
        maxHeight: 1000,
        quality: 0.82,
      });

      setCompressionStats({
        orig: formatBytes(compressed.originalSize),
        comp: formatBytes(compressed.compressedSize),
        savings: compressed.savingsPercent,
        preview: compressed.previewUrl,
        fileName: file.name,
      });

      // 2. Upload to Storage Service (Supabase Storage / Cloudinary)
      try {
        const result = await uploadPetImage(compressed.blob, petName);
        onChange(result.url);
        setProviderUsed(result.provider);
        setUploadSuccess(true);
      } catch (uploadErr) {
        console.warn('Storage upload notice:', uploadErr);
        if (uploadErr.code === 'STORAGE_RLS_POLICY_MISSING') {
          // If Supabase RLS is not configured yet, use compressed data URL so the user isn't blocked!
          const reader = new FileReader();
          reader.readAsDataURL(compressed.blob);
          reader.onloadend = () => {
            onChange(reader.result);
            setProviderUsed('Local Optimized (Storage policy needed for remote bucket)');
            setUploadSuccess(true);
            setErrorMessage(uploadErr.message);
          };
        } else {
          throw uploadErr;
        }
      }
    } catch (err) {
      console.error('Upload error:', err);
      setErrorMessage(err.message || 'Failed to process or upload image.');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragging(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFileSelected(e.dataTransfer.files[0]);
    }
  };

  const handleClearPhoto = () => {
    onChange('');
    setCompressionStats(null);
    setUploadSuccess(false);
    setErrorMessage('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="image-uploader-container">
      {/* Upload mode tabs */}
      <div className="upload-tabs">
        <button
          type="button"
          className={`upload-tab-btn ${activeTab === 'file' ? 'active' : ''}`}
          onClick={() => setActiveTab('file')}
        >
          <FiUploadCloud /> Upload from Device
        </button>
        <button
          type="button"
          className={`upload-tab-btn ${activeTab === 'url' ? 'active' : ''}`}
          onClick={() => setActiveTab('url')}
        >
          <FiLink /> Paste Image URL
        </button>
      </div>

      {activeTab === 'file' ? (
        <div>
          {/* Active / Uploaded Photo Preview Card */}
          {currentUrl ? (
            <div className="upload-status-card">
              <div className="upload-thumb-wrap">
                <img
                  src={currentUrl}
                  alt={petName}
                  className="upload-thumb-img"
                  onError={(e) => { e.target.style.display = 'none'; }}
                />
              </div>
              <div className="upload-meta">
                <div className="upload-file-name">
                  {compressionStats?.fileName || `${petName} Photo`}
                </div>
                {compressionStats && (
                  <div className="upload-savings-tag" title="Client-side auto-compression savings">
                    <FiZap /> {compressionStats.orig} &rarr; {compressionStats.comp} ({compressionStats.savings}% saved)
                  </div>
                )}
                <span className="upload-state-text">
                  {uploadSuccess && <span style={{ color: '#059669', display: 'inline-flex', alignItems: 'center', gap: 4 }}><FiCheckCircle /> Uploaded ({providerUsed})</span>}
                  {!uploadSuccess && 'Active Photo'}
                </span>
              </div>
              <button
                type="button"
                className="btn-remove-photo"
                onClick={handleClearPhoto}
                title="Remove photo"
              >
                <FiTrash2 /> Remove
              </button>
            </div>
          ) : (
            /* Dropzone Box */
            <div
              className={`dropzone-box ${isDragging ? 'dragging' : ''}`}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onDrop={handleDrop}
              onClick={() => fileInputRef.current?.click()}
            >
              <input
                ref={fileInputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp,image/gif"
                className="dropzone-file-input"
                onChange={(e) => handleFileSelected(e.target.files[0])}
                disabled={isProcessing}
              />
              {isProcessing ? (
                <>
                  <FiRefreshCw className="dropzone-icon spin-icon" />
                  <p className="dropzone-title">Uploading...</p>
                  <p className="dropzone-sub">Processing image file</p>
                </>
              ) : (
                <>
                  <FiUploadCloud className="dropzone-icon" />
                  <p className="dropzone-title">Click to upload or drag &amp; drop pet photo</p>
                  <p className="dropzone-sub">JPG, PNG, or WebP</p>
                </>
              )}
            </div>
          )}

          {errorMessage && (
            <div className="storage-notice-banner warn" style={{ marginTop: '8px' }}>
              <FiAlertCircle style={{ fontSize: '15px', flexShrink: 0, marginTop: '1px' }} />
              <div>
                <strong>Notice:</strong> {errorMessage}
              </div>
            </div>
          )}
        </div>
      ) : (
        /* Direct URL tab */
        <div className="image-input-group">
          <input
            type="url"
            placeholder="https://... direct image link"
            value={currentUrl}
            onChange={(e) => onChange(e.target.value)}
          />
          {currentUrl && (
            <div className="modal-image-preview">
              <img
                src={currentUrl}
                alt="Preview"
                onError={(e) => { e.target.style.display = 'none'; }}
                onLoad={(e) => { e.target.style.display = 'block'; }}
              />
              <span>Preview</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
