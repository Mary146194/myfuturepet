import { supabase } from '../config/supabaseClient';

/**
 * Uploads a compressed image blob or file to the configured storage service.
 * Primary: Supabase Storage ('pet-photos' bucket)
 * Fallback: Cloudinary (if configured in .env) or Cloudflare R2 worker (if configured)
 */
export async function uploadPetImage(fileBlob, petName = 'pet') {
  const sanitizedName = (petName || 'pet')
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '_')
    .slice(0, 30);
  const timestamp = Date.now();
  const fileName = `${sanitizedName}_${timestamp}.jpg`;
  const filePath = `uploads/${fileName}`;

  // 1. Check if Cloudinary is configured via environment variables
  const cloudinaryCloud = process.env.REACT_APP_CLOUDINARY_CLOUD_NAME;
  const cloudinaryPreset = process.env.REACT_APP_CLOUDINARY_UPLOAD_PRESET;

  if (cloudinaryCloud && cloudinaryPreset) {
    try {
      const formData = new FormData();
      formData.append('file', fileBlob, fileName);
      formData.append('upload_preset', cloudinaryPreset);
      formData.append('folder', 'myfuturepet');

      const res = await fetch(`https://api.cloudinary.com/v1_1/${cloudinaryCloud}/image/upload`, {
        method: 'POST',
        body: formData,
      });

      if (!res.ok) {
        const errJson = await res.json().catch(() => ({}));
        throw new Error(errJson?.error?.message || `Cloudinary upload failed (${res.status})`);
      }

      const data = await res.json();
      return {
        url: data.secure_url || data.url,
        provider: 'Cloudinary (Free Tier)',
        path: data.public_id,
      };
    } catch (cErr) {
      console.warn('Cloudinary upload failed, falling back to Supabase:', cErr);
    }
  }

  // 2. Default: Supabase Storage ('pet-photos' bucket)
  const { error: uploadError } = await supabase.storage
    .from('pet-photos')
    .upload(filePath, fileBlob, {
      contentType: 'image/jpeg',
      cacheControl: '3600',
      upsert: true,
    });

  if (uploadError) {
    // Provide a descriptive error if RLS policy on storage is missing
    if (uploadError.message?.includes('violates row-level security policy') || uploadError.statusCode === '403') {
      const err = new Error(
        'Supabase Storage permissions need to be enabled for pet-photos. ' +
        'Please run migration "003_storage_policies.sql" in your Supabase SQL Editor.'
      );
      err.code = 'STORAGE_RLS_POLICY_MISSING';
      throw err;
    }
    throw uploadError;
  }

  // Get the public URL for the uploaded asset
  const { data: urlData } = supabase.storage
    .from('pet-photos')
    .getPublicUrl(filePath);

  return {
    url: urlData.publicUrl,
    provider: 'Supabase Storage',
    path: filePath,
  };
}
