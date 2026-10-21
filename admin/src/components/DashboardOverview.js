import React, { useCallback, useEffect, useState } from 'react';
import { FiArrowRight, FiCalendar, FiCheck, FiClipboard, FiRefreshCw, FiUsers } from 'react-icons/fi';
import { MdPets } from 'react-icons/md';
import { supabase } from '../config/supabaseClient';
import './DashboardOverview.css';

const dateLabel = value => new Date(value).toLocaleDateString('en-PH', { timeZone: 'Asia/Manila', month: 'short', day: 'numeric' });
const visitTime = value => new Date(value).toLocaleTimeString('en-PH', { timeZone: 'Asia/Manila', hour: 'numeric', minute: '2-digit' });

function DashboardOverview({ onNavigate }) {
  const [records, setRecords] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const responses = await Promise.all([
        (async () => {
          const result = await supabase.rpc('admin_list_profiles').order('created_at', { ascending: false });
          if (!result.error) return result;
          return supabase.from('profiles').select('id, full_name, role, created_at').order('created_at', { ascending: false });
        })(),
        supabase.from('pets').select('id, name, breed, status, type, image_url, created_at').order('created_at', { ascending: false }),
        supabase.from('adoption_applications').select('id, status, created_at, applicant_id, pet_id').order('created_at', { ascending: false }),
        supabase.from('appointments').select('id, status, scheduled_at').gte('scheduled_at', new Date().toISOString()).order('scheduled_at', { ascending: true }),
      ]);
      if (responses.some(response => response.error)) throw new Error('Dashboard query failed');
      setRecords({ people: responses[0].data || [], pets: responses[1].data || [], applications: responses[2].data || [], visits: responses[3].data || [] });
    } catch {
      setError('We couldn’t load the overview. Please try again.');
    } finally {
      setLoading(false);
    }
  }, []);
  useEffect(() => { load(); }, [load]);

  if (loading && !records) return <div className="shelter-skeleton" role="status" aria-label="Loading shelter overview"><div /><div /><div /><div /><span>Loading your shelter overview…</span></div>;
  if (!records) return <section className="overview-failure" role="alert"><h2>Overview unavailable</h2><p>{error}</p><button onClick={load}><FiRefreshCw /> Try again</button></section>;

  const { people, pets, applications, visits } = records;
  const pending = applications.filter(item => ['pending', 'under_review'].includes(item.status));
  const upcoming = visits.filter(item => ['pending', 'confirmed'].includes(item.status));
  const available = pets.filter(item => item.status === 'available');
  const adopted = pets.filter(item => item.status === 'adopted');
  const adopters = people.filter(item => item.role === 'adopter');
  const total = applications.length;
  const stages = [
    { label: 'Awaiting review', count: pending.length, tone: 'pending' },
    { label: 'Approved', count: applications.filter(item => item.status === 'approved').length, tone: 'approved' },
    { label: 'Other outcomes', count: applications.filter(item => !['pending', 'under_review', 'approved'].includes(item.status)).length, tone: 'other' },
  ];
  const metrics = [
    { label: 'Available for adoption', value: available.length, detail: `${pets.length} rescue profiles`, icon: MdPets, route: 'pets' },
    { label: 'Applications to review', value: pending.length, detail: 'Pending and under review', icon: FiClipboard, route: 'adoptions' },
    { label: 'Upcoming visits', value: upcoming.length, detail: 'Pending and confirmed', icon: FiCalendar, route: 'appointments' },
    { label: 'Adopted pets', value: adopted.length, detail: 'Across your visible records', icon: FiCheck, route: 'pets' },
  ];

  return <div className="shelter-overview" aria-busy={loading}>
    {error && <div className="overview-inline-error" role="alert">{error} <button onClick={load}>Retry</button></div>}
    <section className="work-summary" aria-labelledby="work-summary-title">
      <div><h2 id="work-summary-title">A clear view of the work ahead.</h2><p>{pending.length ? `${pending.length} ${pending.length === 1 ? 'application is' : 'applications are'} waiting for your team’s attention.` : 'Your application review queue is clear.'} Keep the next steps moving.</p></div>
      <button onClick={() => onNavigate('adoptions')}>Review applications <FiArrowRight aria-hidden="true" /></button>
    </section>
    <section className="overview-metrics" aria-label="Shelter totals">
      {metrics.map(item => { const Icon = item.icon; return <button key={item.label} className="overview-metric" onClick={() => onNavigate(item.route)}>
        <span className="metric-heading">{item.label}<Icon aria-hidden="true" /></span><strong>{item.value}</strong><span className="metric-detail">{item.detail}<FiArrowRight aria-hidden="true" /></span>
      </button>; })}
    </section>
    <div className="overview-work-grid">
      <section className="work-panel review-panel" aria-labelledby="review-heading">
        <header className="work-panel-header"><div><h2 id="review-heading">Application inbox</h2><p>The latest requests awaiting a decision.</p></div><button onClick={() => onNavigate('adoptions')}>View all <FiArrowRight aria-hidden="true" /></button></header>
        {pending.length ? <ul className="review-list">{pending.slice(0, 4).map(item => { const pet = pets.find(pet => pet.id === item.pet_id); return <li key={item.id}><span className="record-symbol"><FiClipboard aria-hidden="true" /></span><div className="record-copy"><strong>{pet?.name ? `Adoption request for ${pet.name}` : `Application #${item.id.slice(0, 6).toUpperCase()}`}</strong><span>Submitted {dateLabel(item.created_at)}</span></div><span className="work-status">{item.status === 'under_review' ? 'In review' : 'Pending'}</span><button className="record-open" aria-label={`Review application ${item.id}`} onClick={() => onNavigate('adoptions')}><FiArrowRight aria-hidden="true" /></button></li>; })}</ul> : <div className="work-empty"><FiCheck aria-hidden="true" /><h3>All caught up.</h3><p>New applications will appear here when adopters submit them.</p></div>}
        <footer className="panel-footnote"><FiUsers aria-hidden="true" /><span>{adopters.length} registered {adopters.length === 1 ? 'adopter' : 'adopters'} across your visible records</span></footer>
      </section>
      <section className="work-panel visits-panel" aria-labelledby="visits-heading">
        <header className="work-panel-header"><div><h2 id="visits-heading">Next shelter visits</h2><p>Scheduled in Philippine time.</p></div><button onClick={() => onNavigate('appointments')} aria-label="View all appointments"><FiArrowRight aria-hidden="true" /></button></header>
        {upcoming.length ? <ul className="visit-list">{upcoming.slice(0, 3).map(item => <li key={item.id}><time className="visit-date" dateTime={item.scheduled_at}>{dateLabel(item.scheduled_at)}</time><div><strong>{visitTime(item.scheduled_at)}</strong><span>{item.status === 'confirmed' ? 'Confirmed visit' : 'Awaiting confirmation'}</span></div><button className="record-open" aria-label={`Open appointment ${item.id}`} onClick={() => onNavigate('appointments')}><FiArrowRight aria-hidden="true" /></button></li>)}</ul> : <div className="work-empty"><FiCalendar aria-hidden="true" /><h3>Room for a new introduction.</h3><p>Upcoming bookings will appear here.</p></div>}
      </section>
    </div>
    <div className="overview-detail-grid">
      <section className="work-panel pet-roster" aria-labelledby="rescue-heading">
        <header className="work-panel-header"><div><h2 id="rescue-heading">Recently added rescues</h2><p>The latest profiles in your shelter records.</p></div><button onClick={() => onNavigate('pets')}>Pet records <FiArrowRight aria-hidden="true" /></button></header>
        {pets.length ? <div className="roster-scroll"><table><thead><tr><th>Pet</th><th>Breed / type</th><th>Status</th><th>Added</th></tr></thead><tbody>{pets.slice(0, 4).map(pet => <tr key={pet.id}><td><span className="roster-name"><span className="pet-initial" aria-hidden="true">{pet.name?.charAt(0) || <MdPets />}</span><strong>{pet.name || 'Unnamed rescue'}</strong></span></td><td>{pet.breed || pet.type || 'Not recorded'}</td><td><span className={`roster-status ${pet.status}`}>{pet.status || 'Not recorded'}</span></td><td>{dateLabel(pet.created_at)}</td></tr>)}</tbody></table></div> : <div className="work-empty"><MdPets aria-hidden="true" /><h3>Every rescue starts with a record.</h3><p>Add and manage rescue profiles in Pet records.</p></div>}
      </section>
      <section className="work-panel adoption-breakdown" aria-labelledby="breakdown-heading">
        <header className="work-panel-header"><div><h2 id="breakdown-heading">Application overview</h2><p>All visible applications</p></div></header><div className="breakdown-total"><strong>{total}</strong><span>total applications</span></div>
        <div className="breakdown-bar" aria-hidden="true">{stages.map(stage => <span className={stage.tone} key={stage.label} style={{ flexGrow: stage.count }} />)}</div>
        <ul>{stages.map(stage => <li key={stage.label}><span><i className={stage.tone} aria-hidden="true" />{stage.label}</span><strong>{stage.count}</strong></li>)}</ul>
      </section>
    </div>
    <footer className="overview-footer"><span>Jagna Animal Lover and Rescue Group</span><button disabled={loading} onClick={load}><FiRefreshCw aria-hidden="true" />{loading ? 'Refreshing…' : 'Refresh overview'}</button></footer>
  </div>;
}
export default DashboardOverview;
