import React, { useState, useEffect } from 'react';
import { Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom';
import { supabase } from './config/supabaseClient';
import LandingPage from './pages/LandingPage';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import './App.css';

function App() {
  const [user, setUser] = useState(null);
  const [isAdmin, setIsAdmin] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { pathname } = useLocation();

  useEffect(() => {
    document.title = pathname === '/sign-in' ? 'Staff sign in | My Future Pet' : user ? 'Admin workspace | My Future Pet' : 'My Future Pet | Shelter workspace';
    window.scrollTo(0, 0);
  }, [pathname, user]);

  const loadProfile = async sessionUser => {
    if (!sessionUser) { setIsAdmin(null); return; }
    const { data, error } = await supabase.from('profiles').select('is_admin, role, full_name, shelter_id').eq('id', sessionUser.id).single();
    setIsAdmin(!error && (data?.is_admin === true || data?.role === 'admin' || data?.role === 'shelter_staff'));
  };

  useEffect(() => {
    const checkUser = async () => {
      try {
        const { data } = await supabase.auth.getSession();
        if (data.session) { setUser(data.session.user); await loadProfile(data.session.user); }
      } catch { setUser(null); setIsAdmin(null); }
      finally { setLoading(false); }
    };
    checkUser();
    const { data: authListener } = supabase.auth.onAuthStateChange((event, session) => {
      if (session) { setUser(session.user); loadProfile(session.user); }
      else { setUser(null); setIsAdmin(null); }
    });
    return () => authListener?.subscription.unsubscribe();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    setUser(null); setIsAdmin(null); navigate('/', { replace: true });
  };
  const handleLoginSuccess = sessionUser => {
    setIsAdmin(null); setUser(sessionUser); loadProfile(sessionUser); navigate('/', { replace: true });
  };

  if (loading || (user && isAdmin === null)) return <div className="app-session-loading" role="status">Loading your workspace…</div>;
  if (user && !isAdmin) return <div className="app-access-denied"><h1>Access denied</h1><p>Your account does not have staff or administrator access.</p><button onClick={handleLogout}>Sign out</button></div>;

  return <div className="App"><Routes>
    <Route path="/" element={user && isAdmin ? <DashboardPage user={user} onLogout={handleLogout} /> : <LandingPage />} />
    <Route path="/sign-in" element={user ? <Navigate to="/" replace /> : <LoginPage onLoginSuccess={handleLoginSuccess} />} />
    <Route path="*" element={<Navigate to="/" replace />} />
  </Routes></div>;
}
export default App;
