import React, { useRef, useState } from 'react';
import { FiArrowRight, FiEye, FiEyeOff, FiMapPin, FiAlertCircle, FiChevronDown, FiLoader } from 'react-icons/fi';
import { PiPawPrintDuotone, PiClipboardTextDuotone, PiCalendarDotsDuotone } from 'react-icons/pi';
import { supabase } from '../config/supabaseClient';
import appLogo from '../assets/logo.png';
import './LoginPage.css';
import './PublicTypography.css';

function LoginPage({ onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [capsLock, setCapsLock] = useState(false);
  const [helpOpen, setHelpOpen] = useState(false);
  const [errors, setErrors] = useState({});
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const emailRef = useRef(null);
  const passwordRef = useRef(null);
  const pending = useRef(false);

  const handleLogin = async event => {
    event.preventDefault();
    if (pending.current) return;
    const nextErrors = {};
    const cleanEmail = email.trim();
    if (!cleanEmail) nextErrors.email = 'Enter your email address.';
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(cleanEmail)) nextErrors.email = 'Enter a valid email address.';
    if (!password) nextErrors.password = 'Enter your password.';
    setErrors(nextErrors);
    setError('');
    if (Object.keys(nextErrors).length) {
      (nextErrors.email ? emailRef : passwordRef).current?.focus();
      return;
    }
    pending.current = true;
    setLoading(true);
    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({ email: cleanEmail, password });
      if (authError) setError(authError.message || 'Sign-in failed. Check your details and try again.');
      else if (data?.user) onLoginSuccess(data.user);
      else setError('Sign-in could not be completed. Please try again.');
    } catch {
      setError('We couldn’t connect. Check your connection and try again.');
    } finally {
      pending.current = false;
      setLoading(false);
    }
  };

  return (
    <div className="portal-shell">
      <header className="portal-topbar">
        <div className="topbar-inner">
          <div className="topbar-brand">
            <img src={appLogo} alt="My Future Pet logo" width="44" height="44" className="topbar-logo" />
            <div className="topbar-title-wrap"><span className="topbar-app-name">My Future Pet</span><span className="topbar-app-tag">Administrative Console</span></div>
          </div>
          <span className="topbar-location"><FiMapPin aria-hidden="true" /> Jagna, Bohol</span>
        </div>
      </header>
      <main className="portal-main">
        <a href="/" className="signin-back">Back to website</a>
        <section className="portal-auth" aria-labelledby="sign-in-heading">
          <div className="auth-card-header"><h1 id="sign-in-heading">Welcome back.</h1><p>Sign in to your admin workspace.</p></div>
          {error && <div className="auth-error-banner" role="alert"><FiAlertCircle aria-hidden="true" /><span>{error}</span></div>}
          <form onSubmit={handleLogin} className="auth-form" noValidate aria-busy={loading}>
            <div className="form-field">
              <label htmlFor="staff-email">Email address</label>
              <input ref={emailRef} id="staff-email" type="email" value={email} onChange={event => { setEmail(event.target.value); setErrors(current => ({...current, email: ''})); }} placeholder="name@example.com" required autoComplete="email" autoCapitalize="none" spellCheck={false} disabled={loading} aria-invalid={!!errors.email} aria-describedby={errors.email ? 'email-error' : undefined} />
              {errors.email && <span id="email-error" className="field-error">{errors.email}</span>}
            </div>
            <div className="form-field">
              <label htmlFor="staff-password">Password</label>
              <div className="input-group">
                <input ref={passwordRef} id="staff-password" type={showPassword ? 'text' : 'password'} value={password} onChange={event => { setPassword(event.target.value); setErrors(current => ({...current, password: ''})); }} onKeyDown={event => setCapsLock(event.getModifierState('CapsLock'))} onKeyUp={event => setCapsLock(event.getModifierState('CapsLock'))} onBlur={() => setCapsLock(false)} placeholder="Enter password" required autoComplete="current-password" disabled={loading} aria-invalid={!!errors.password} aria-describedby={[errors.password && 'password-error', capsLock && 'caps-lock-note'].filter(Boolean).join(' ') || undefined} />
                <button type="button" className="field-toggle-btn" aria-label={showPassword ? 'Hide password' : 'Show password'} aria-pressed={showPassword} onClick={() => setShowPassword(value => !value)}>{showPassword ? <FiEyeOff aria-hidden="true" /> : <FiEye aria-hidden="true" />}</button>
              </div>
              {errors.password && <span id="password-error" className="field-error">{errors.password}</span>}
              {capsLock && <span id="caps-lock-note" className="caps-lock-note" role="status">Caps Lock is on.</span>}
            </div>
            <button type="submit" className="auth-submit-btn" disabled={loading}><span>{loading ? 'Signing in…' : 'Sign In to Console'}</span>{loading ? <FiLoader className="login-spinner" aria-hidden="true" /> : <FiArrowRight aria-hidden="true" />}</button>
          </form>
          <div className="account-help">
            <button type="button" aria-expanded={helpOpen} aria-controls="account-help-content" onClick={() => setHelpOpen(value => !value)}>Need help signing in?<FiChevronDown className={helpOpen ? 'help-chevron expanded' : 'help-chevron'} aria-hidden="true" /></button>
            <div id="account-help-content" hidden={!helpOpen}><p>Use the account registered with your shelter. Contact your shelter administrator if you need access or help recovering your account.</p></div>
          </div>
        </section>
        <section className="workspace-context" aria-label="Shelter workspace">
          <div className="workspace-capabilities"><span><PiPawPrintDuotone aria-hidden="true" />Rescue records</span><span><PiClipboardTextDuotone aria-hidden="true" />Adoption reviews</span><span><PiCalendarDotsDuotone aria-hidden="true" />Shelter visits</span></div>
          <p>Jagna Animal Lover and Rescue Group</p>
        </section>
      </main>
      <footer className="portal-footer"><span>My Future Pet &copy; {new Date().getFullYear()}</span><span>Administration only</span></footer>
    </div>
  );
}
export default LoginPage;
