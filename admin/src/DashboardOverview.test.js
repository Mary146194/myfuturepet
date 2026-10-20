import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import DashboardOverview from './components/DashboardOverview';
import DashboardPage from './pages/DashboardPage';

let mockFail = false;
const mockRows = {
  profiles: [{ id: 'person-a', full_name: 'Example adopter', role: 'adopter', created_at: '2026-10-19T02:00:00Z' }],
  pets: [
    { id: 'pet-a', name: 'Milo', breed: 'Aspin', type: 'dog', status: 'available', created_at: '2026-10-19T02:00:00Z' },
    { id: 'pet-b', name: 'Luna', breed: 'Puspin', type: 'cat', status: 'available', created_at: '2026-10-18T02:00:00Z' },
    { id: 'pet-c', name: 'Coco', breed: 'Aspin', type: 'dog', status: 'adopted', created_at: '2026-10-17T02:00:00Z' },
  ],
  adoption_applications: [
    { id: 'application-a', pet_id: 'pet-a', status: 'pending', created_at: '2026-10-20T02:00:00Z' },
    { id: 'application-b', pet_id: 'pet-b', status: 'under_review', created_at: '2026-10-19T02:00:00Z' },
    { id: 'application-c', pet_id: 'pet-c', status: 'approved', created_at: '2026-10-18T02:00:00Z' },
  ],
  appointments: [
    { id: 'visit-a', status: 'confirmed', scheduled_at: '2026-10-24T01:30:00Z' },
    { id: 'visit-b', status: 'pending', scheduled_at: '2026-10-24T06:00:00Z' },
  ],
};
jest.mock('./config/supabaseClient', () => {
  const query = table => {
    const chain = new Proxy({}, { get: (_, key) => key === 'then' ? resolve => Promise.resolve({ data: mockFail ? null : mockRows[table] || [], count: 2, error: mockFail ? { message: 'Unavailable' } : null }).then(resolve) : () => chain });
    return chain;
  };
  return { supabase: { from: query, rpc: () => query('profiles') } };
});
beforeEach(() => { mockFail = false; });

test('shows real fixture totals, linked pet names, and Philippine visit times', async () => {
  const onNavigate = jest.fn();
  render(<DashboardOverview onNavigate={onNavigate} />);
  expect(screen.getByRole('status')).toHaveTextContent('Loading your shelter overview');
  expect(await screen.findByText('Adoption request for Milo')).toBeInTheDocument();
  expect(screen.getByText('Adoption request for Luna')).toBeInTheDocument();
  expect(screen.getByText('9:30 AM')).toBeInTheDocument();
  expect(screen.getByRole('button', { name: /Available for adoption/ })).toHaveTextContent('2');
  expect(screen.getByRole('button', { name: /Adopted pets/ })).toHaveTextContent('1');
  fireEvent.click(screen.getByRole('button', { name: 'Review applications' }));
  expect(onNavigate).toHaveBeenCalledWith('adoptions');
  fireEvent.click(screen.getByRole('button', { name: 'Open appointment visit-a' }));
  expect(onNavigate).toHaveBeenCalledWith('appointments');
  expect(screen.queryByText('Live & Healthy')).not.toBeInTheDocument();
});

test('reports query failure and recovers through retry', async () => {
  mockFail = true;
  render(<DashboardOverview onNavigate={jest.fn()} />);
  expect(await screen.findByRole('alert')).toHaveTextContent('We couldn’t load the overview');
  mockFail = false;
  fireEvent.click(screen.getByRole('button', { name: 'Try again' }));
  expect(await screen.findByText('Adoption request for Milo')).toBeInTheDocument();
});

test('account menu and workspace selector are keyboard-accessible controls', async () => {
  localStorage.clear();
  const { container } = render(<DashboardPage user={{email:'admin@example.test'}} onLogout={() => {}} />);
  await screen.findByText('Adoption request for Milo');
  fireEvent.click(screen.getByRole('button', { name: 'Account options' }));
  expect(screen.getByRole('button', { name: 'Account options' })).toHaveAttribute('aria-expanded', 'true');
  expect(screen.getByRole('button', { name: 'Sign Out' })).toBeInTheDocument();
  if (process.env.REVIEW_ARTIFACT_DIR) {
    const fs = require('fs');
    const path = require('path');
    fireEvent.click(screen.getByRole('button', { name: 'Account options' }));
    fs.writeFileSync(path.join(process.env.REVIEW_ARTIFACT_DIR, 'premium-dashboard.html'), '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Dashboard design review — sample records</title><link rel="stylesheet" href="review.css"><link rel="stylesheet" href="workspace.css"></head><body>' + container.innerHTML + '</body></html>');
  }
  fireEvent.change(screen.getByRole('combobox', { name: 'Go to workspace section' }), {target:{value:'reports'}});
  await waitFor(() => expect(screen.getByRole('navigation').querySelector('[aria-current=page]')).toHaveTextContent('Reports'));
});
