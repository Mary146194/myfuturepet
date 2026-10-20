import React, { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { FiArrowRight, FiArrowUpRight, FiCheck, FiChevronDown, FiMenu, FiX } from 'react-icons/fi';
import { PiPawPrintDuotone, PiClipboardTextDuotone, PiCalendarDotsDuotone } from 'react-icons/pi';
import logo from '../assets/logo.png';
import heroSmall from '../assets/landing/rescue-portrait-720.webp';
import heroLarge from '../assets/landing/rescue-portrait-1440.webp';
import careSmall from '../assets/landing/animal-care-720.webp';
import careLarge from '../assets/landing/animal-care-1440.webp';
import './PublicTypography.css';
import './LandingPage.css';

const features = [
  { id: 'records', name: 'Rescue records', icon: PiPawPrintDuotone, title: 'Know the story behind every rescue.', description: 'Bring pet profiles, health information, and adoption status together, so the next person caring for a rescue has the details they need.', points: ['Maintain profiles and rescue backgrounds', 'Keep vaccination and health details together', 'Update availability as each journey progresses'], note: 'From the first record to a new beginning.' },
  { id: 'reviews', name: 'Adoption reviews', icon: PiClipboardTextDuotone, title: 'Give every application a considered next step.', description: 'Review adoption responses in one staff workspace. Keep applicant information and review decisions connected to the right pet.', points: ['Read submitted adoption questionnaires', 'Track applications awaiting a decision', 'Manage review outcomes in one place'], note: 'Thoughtful decisions, with the details in view.' },
  { id: 'visits', name: 'Shelter visits', icon: PiCalendarDotsDuotone, title: 'Make space for the next introduction.', description: 'Coordinate shelter visits and meet-and-greets, with booking details and appointment status available to the team.', points: ['Review upcoming visit requests', 'Confirm and manage appointments', 'Keep shelter schedules easy to follow'], note: 'A little organization. A more personal welcome.' },
];

function FeatureContent({ feature }) {
  return <div className="feature-copy"><h3>{feature.title}</h3><p>{feature.description}</p><ul>{feature.points.map(point => <li key={point}><FiCheck aria-hidden="true" />{point}</li>)}</ul><span className="feature-note">{feature.note}</span></div>;
}

function EditorialPhoto({ small, large, alt, className, priority = false }) {
  const [failed, setFailed] = useState(false);
  return <div className={`editorial-photo ${className || ''}`}>
    {failed ? <div className="photo-fallback"><PiPawPrintDuotone aria-hidden="true" /><span>Care for every new beginning.</span></div> : <img src={large} srcSet={`${small} 720w, ${large} 1440w`} sizes="(max-width: 767px) calc(100vw - 40px), (max-width: 1280px) 48vw, 600px" alt={alt} width="1440" height={priority ? '1080' : '2160'} loading={priority ? 'eager' : 'lazy'} fetchPriority={priority ? 'high' : 'auto'} onError={() => setFailed(true)} />}
  </div>;
}

export default function LandingPage() {
  const [navOpen, setNavOpen] = useState(false);
  const [active, setActive] = useState(0);
  const menuButton = useRef(null);
  const tabRefs = useRef([]);
  useEffect(() => {
    const escape = event => {
      if (event.key === 'Escape' && navOpen) { setNavOpen(false); menuButton.current?.focus(); }
    };
    document.addEventListener('keydown', escape);
    return () => document.removeEventListener('keydown', escape);
  }, [navOpen]);
  useEffect(() => {
    if (!window.matchMedia) return;
    const media = window.matchMedia('(min-width: 768px)');
    const closeOnDesktop = () => { if (media.matches) setNavOpen(false); };
    media.addEventListener('change', closeOnDesktop);
    return () => media.removeEventListener('change', closeOnDesktop);
  }, []);
  const tabKey = (event, index) => {
    const next = { ArrowRight: (index + 1) % 3, ArrowLeft: (index + 2) % 3, Home: 0, End: 2 }[event.key];
    if (next === undefined) return;
    event.preventDefault(); setActive(next); tabRefs.current[next]?.focus();
  };

  return <div className="public-landing">
    <a className="landing-skip" href="#landing-main">Skip to content</a>
    <header className="landing-header">
      <div className="landing-container header-layout">
        <Link to="/" className="landing-brand" aria-label="My Future Pet home"><img src={logo} width="44" height="44" alt="" /><span>My Future Pet<small>For the people behind every rescue.</small></span></Link>
        <button ref={menuButton} className="landing-menu" aria-label={navOpen ? 'Close navigation' : 'Open navigation'} aria-expanded={navOpen} aria-controls="public-navigation" onClick={() => setNavOpen(value => !value)}>{navOpen ? <FiX /> : <FiMenu />}</button>
        <nav id="public-navigation" className={`public-navigation ${navOpen ? 'is-open' : ''}`} aria-label="Main navigation">
          <a href="#workspace" onClick={() => setNavOpen(false)}>Workspace</a><a href="#shelter" onClick={() => setNavOpen(false)}>Partner shelter</a><a href="#support" onClick={() => setNavOpen(false)}>Support</a>
          <Link to="/sign-in" className="landing-button header-signin" onClick={() => setNavOpen(false)}>Staff sign in <FiArrowUpRight aria-hidden="true" /></Link>
        </nav>
      </div>
    </header>
    <main id="landing-main" tabIndex="-1">
      <section className="landing-hero landing-container" aria-labelledby="hero-heading">
        <div className="hero-copy"><h1 id="hero-heading">Behind every<br />new beginning,<br /><span>there’s good care.</span></h1><p>A thoughtful workspace for the people making rescue and adoption happen. Keep the records, reviews, and visits together. Keep your attention on the animals.</p><div className="hero-actions"><Link to="/sign-in" className="landing-button">Staff sign in <FiArrowRight aria-hidden="true" /></Link><a href="#workspace" className="landing-text-link">Explore the workspace <FiArrowDownIcon /></a></div><div className="hero-partner"><span>Supporting the work of</span><strong>Jagna Animal Lover and Rescue Group</strong><small>Jagna, Bohol, Philippines</small></div></div>
        <figure className="hero-photo"><EditorialPhoto small={heroSmall} large={heroLarge} alt="A brown dog looking up attentively on a woodland path" priority /><figcaption>Every rescue has a story worth keeping.<small>Illustrative stock photography</small></figcaption></figure>
      </section>
      <section tabIndex="-1" id="workspace" className="workspace-section" aria-labelledby="workspace-heading">
        <div className="landing-container"><div className="section-heading"><h2 id="workspace-heading">Less scattered work.<br /><span>More room for care.</span></h2><p>The everyday details matter. Give your team one place to follow them through.</p></div>
          <div className="desktop-features"><div className="feature-tabs" role="tablist" aria-label="Workspace features">{features.map((feature, index) => { const Icon = feature.icon; return <button key={feature.id} ref={element => { tabRefs.current[index] = element; }} id={`tab-${feature.id}`} role="tab" aria-selected={active === index} aria-controls={`panel-${feature.id}`} tabIndex={active === index ? 0 : -1} onClick={() => setActive(index)} onKeyDown={event => tabKey(event, index)}><Icon aria-hidden="true" />{feature.name}<FiArrowUpRight aria-hidden="true" /></button>; })}</div>{features.map((feature, index) => <div key={feature.id} className="feature-panel" role="tabpanel" id={`panel-${feature.id}`} aria-labelledby={`tab-${feature.id}`} hidden={active !== index} tabIndex="0"><FeatureContent feature={feature} /></div>)}</div>
          <div className="mobile-features">{features.map((feature, index) => { const Icon = feature.icon; return <details key={feature.id} open={index === 0 ? true : undefined}><summary><Icon aria-hidden="true" />{feature.name}<FiChevronDown aria-hidden="true" /></summary><FeatureContent feature={feature} /></details>; })}</div>
        </div>
      </section>
      <section tabIndex="-1" id="shelter" className="shelter-section landing-container" aria-labelledby="shelter-heading">
        <figure><EditorialPhoto small={careSmall} large={careLarge} alt="A person gently stroking a golden dog's head outdoors" className="care-photo" /><figcaption>Small moments of care make a difference.<small>Illustrative stock photography</small></figcaption></figure>
        <div className="shelter-copy"><h2 id="shelter-heading">Built around the work.<br /><span>And the lives behind it.</span></h2><p>My Future Pet supports Jagna Animal Lover and Rescue Group with the daily work of managing rescue profiles, reviewing adoption applications, and coordinating shelter visits.</p><p>The admin workspace keeps those details connected, alongside the adopter experience in the My Future Pet mobile app.</p><div className="shelter-signature"><PiPawPrintDuotone aria-hidden="true" /><span><strong>Jagna Animal Lover and Rescue Group</strong><small>Partner shelter · Jagna, Bohol</small></span></div></div>
      </section>
      <section tabIndex="-1" id="support" className="support-section" aria-labelledby="support-heading"><div className="landing-container support-layout"><div><h2 id="support-heading">The next good chapter<br />starts with your team.</h2><p>Sign in to pick up the work that matters.</p><Link to="/sign-in" className="landing-button">Enter the staff workspace <FiArrowRight aria-hidden="true" /></Link></div><div className="landing-help"><details><summary>Who can use the admin workspace?<FiChevronDown aria-hidden="true" /></summary><p>The workspace is for registered shelter staff and administrators. Adopters use the My Future Pet mobile app.</p></details><details><summary>How do I get account access?<FiChevronDown aria-hidden="true" /></summary><p>Contact your shelter administrator to request an account or help recovering access. Account registration is managed by the shelter team.</p></details><details><summary>Where do I manage applications and visits?<FiChevronDown aria-hidden="true" /></summary><p>After signing in, open Adoption reviews or Appointments from the dashboard navigation.</p></details></div></div></section>
    </main>
    <footer className="landing-footer landing-container"><div className="landing-footer-top"><Link to="/" className="footer-brand">My Future Pet</Link><span>Care, thoughtfully coordinated.</span><a href="#landing-main">Back to top <FiArrowUpRight aria-hidden="true" /></a></div><div className="landing-footer-bottom"><span>© {new Date().getFullYear()} My Future Pet · Administration only</span><details><summary>Photography credits</summary><p>Illustrative images; not photographs of Jagna shelter animals or staff. Dog portrait: <a href="https://unsplash.com/photos/gGLkKJKGf_k" target="_blank" rel="noreferrer">Jamie Street</a>. Animal care: <a href="https://unsplash.com/photos/9xW_qruM380" target="_blank" rel="noreferrer">Maria Lupan</a>. Used under the <a href="https://unsplash.com/license" target="_blank" rel="noreferrer">Unsplash License</a>.</p></details></div></footer>
  </div>;
}
function FiArrowDownIcon() { return <FiArrowRight className="explore-arrow" aria-hidden="true" />; }
