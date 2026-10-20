import React from 'react';
import { render, screen, fireEvent, waitFor, act, within } from '@testing-library/react';
import DashboardPage from './pages/DashboardPage';

jest.mock('./config/supabaseClient', () => {
  const result = { data: [], error: null, count: 0 };
  const query = new Proxy({}, { get: (_, key) => key === 'then'
    ? (resolve) => Promise.resolve(result).then(resolve)
    : () => query });
  return { supabase: {
    from: () => query, rpc: () => query,
    channel: () => query, removeChannel: jest.fn(),
    auth: { getUser: async () => ({ data: { user: { id: 'test-admin' } }, error: null }) },
  } };
});

beforeAll(() => {
  global.ResizeObserver = class { observe() {} disconnect() {} };
});

test('all admin destinations remain accessible after the redesign', async () => {
  localStorage.clear();
  const { container } = render(<DashboardPage user={{ email: 'admin@example.test' }} onLogout={() => {}} />);
  const destinations = ['Dashboard', 'Pet records', 'Adoption reviews', 'Appointments', 'Community Posts', 'Reports', 'Notifications', 'People & access', 'System Logs'];
  for (const name of destinations) {
    const button = within(screen.getByRole('navigation')).getByRole('button', { name, exact: true });
    await act(async () => { fireEvent.click(button); });
    await waitFor(() => expect(button).toHaveAttribute('aria-current', 'page'));
    expect(container.querySelector('.content-area')).not.toBeEmptyDOMElement();
    // Optional offline visual-review artifacts; never included in the application bundle.
    if (process.env.REVIEW_ARTIFACT_DIR) {
      const fs = require('fs');
      const path = require('path');
      fs.mkdirSync(process.env.REVIEW_ARTIFACT_DIR, { recursive: true });
      fs.writeFileSync(path.join(process.env.REVIEW_ARTIFACT_DIR, name.replace(/[^a-z]/gi, '-') + '.html'),
        '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><link rel="stylesheet" href="review.css"><title>Offline design review</title></head><body>' + container.innerHTML + '</body></html>');
    }
  }
});

