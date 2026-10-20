import { render, screen, fireEvent, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import LandingPage from './pages/LandingPage';
const renderPage = () => render(<MemoryRouter><LandingPage /></MemoryRouter>);

test('links staff entry to the dedicated route and exposes real section destinations', () => {
  renderPage();
  expect(screen.getByRole('heading', {level:1})).toHaveTextContent('Behind every');
  screen.getAllByRole('link', {name:/Staff sign in/}).forEach(link => expect(link).toHaveAttribute('href','/sign-in'));
  const nav=screen.getByRole('navigation', {name:'Main navigation'});
  expect(within(nav).getByRole('link',{name:'Workspace'})).toHaveAttribute('href','#workspace');
  expect(screen.getByRole('img',{name:/brown dog/})).toHaveAttribute('srcset');
});

test('mobile menu closes on Escape and returns focus to its trigger', () => {
  renderPage();
  fireEvent.click(screen.getByRole('button',{name:'Open navigation'}));
  const trigger=screen.getByRole('button',{name:'Close navigation'});
  expect(trigger).toHaveAttribute('aria-expanded','true');
  fireEvent.keyDown(document,{key:'Escape'});
  expect(screen.getByRole('button',{name:'Open navigation'})).toHaveFocus();
  expect(screen.getByRole('button',{name:'Open navigation'})).toHaveAttribute('aria-expanded','false');
});

test('workspace tabs switch content with mouse and roving keyboard focus', () => {
  renderPage();
  const reviews=screen.getByRole('tab',{name:'Adoption reviews'});
  fireEvent.click(reviews);
  expect(reviews).toHaveAttribute('aria-selected','true');
  expect(screen.getByRole('tabpanel')).toHaveTextContent('Give every application a considered next step.');
  fireEvent.keyDown(reviews,{key:'ArrowRight'});
  expect(screen.getByRole('tab',{name:'Shelter visits'})).toHaveFocus();
  expect(screen.getByRole('tabpanel')).toHaveTextContent('Make space for the next introduction.');
  fireEvent.keyDown(screen.getByRole('tab',{name:'Shelter visits'}),{key:'Home'});
  expect(screen.getByRole('tab',{name:'Rescue records'})).toHaveFocus();
});

test('failed photography has a readable fallback without removing sign-in', () => {
  renderPage();
  fireEvent.error(screen.getByRole('img',{name:/brown dog/}));
  expect(screen.getByText('Care for every new beginning.')).toBeInTheDocument();
  expect(screen.getAllByRole('link',{name:/Staff sign in/}).length).toBeGreaterThan(0);
});
