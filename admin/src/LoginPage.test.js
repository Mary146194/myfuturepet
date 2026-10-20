import React from 'react';
import { render, screen, fireEvent, within, waitFor, act } from '@testing-library/react';
import LoginPage from './pages/LoginPage';
import { supabase } from './config/supabaseClient';
jest.mock('./config/supabaseClient', () => ({ supabase: { auth: { signInWithPassword: jest.fn() } } }));
beforeEach(() => jest.clearAllMocks());

describe('LoginPage Component Tests', () => {
  test('renders admin overview and staff authentication form', () => {
    render(<LoginPage onLoginSuccess={() => {}} />);

    expect(within(screen.getByRole('banner')).getByText('My Future Pet')).toBeInTheDocument();
    expect(screen.getByText('Administrative Console')).toBeInTheDocument();
    expect(screen.getByText(/Jagna Animal Lover and Rescue Group/i)).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Welcome back.' })).toBeInTheDocument();
    expect(screen.getByRole('heading', { name: 'Welcome back.' })).toBeInTheDocument();
    expect(screen.queryByRole('tablist')).not.toBeInTheDocument();
    expect(screen.queryByText('Operational')).not.toBeInTheDocument();

    expect(screen.getByPlaceholderText('name@example.com')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /Sign In to Console/i })).toBeInTheDocument();
  });

  test('toggles password visibility when the eye button is clicked', () => {
    render(<LoginPage onLoginSuccess={() => {}} />);

    const passwordInput = screen.getByPlaceholderText('Enter password');
    expect(passwordInput).toHaveAttribute('type', 'password');

    const toggleButton = screen.getByRole('button', { name: /Show password/i });
    fireEvent.click(toggleButton);

    expect(passwordInput).toHaveAttribute('type', 'text');

    const hideButton = screen.getByRole('button', { name: /Hide password/i });
    fireEvent.click(hideButton);

    expect(passwordInput).toHaveAttribute('type', 'password');
  });

  test('updates input values when typing in email and password fields', () => {
    render(<LoginPage onLoginSuccess={() => {}} />);

    const emailInput = screen.getByPlaceholderText('name@example.com');
    const passwordInput = screen.getByPlaceholderText('Enter password');

    fireEvent.change(emailInput, { target: { value: 'admin@jalrg.org' } });
    fireEvent.change(passwordInput, { target: { value: 'secretPassword123' } });

    expect(emailInput.value).toBe('admin@jalrg.org');
    expect(passwordInput.value).toBe('secretPassword123');
  });
});


test('shows inline validation and focuses the first invalid field without submitting', () => {
  render(<LoginPage onLoginSuccess={jest.fn()} />);
  fireEvent.click(screen.getByRole('button', { name: /Sign In to Console/i }));
  expect(screen.getByText('Enter your email address.')).toBeInTheDocument();
  expect(screen.getByLabelText('Email address')).toHaveFocus();
  expect(supabase.auth.signInWithPassword).not.toHaveBeenCalled();
});

test('expands and closes account help', () => {
  render(<LoginPage onLoginSuccess={jest.fn()} />);
  const help = screen.getByRole('button', { name: 'Need help signing in?' });
  fireEvent.click(help);
  expect(help).toHaveAttribute('aria-expanded', 'true');
  expect(screen.getByText(/Contact your shelter administrator/)).toBeVisible();
  fireEvent.click(help);
  expect(help).toHaveAttribute('aria-expanded', 'false');
});

test('prevents duplicate submission while loading and reports a rejected sign-in', async () => {
  let resolveLogin;
  supabase.auth.signInWithPassword.mockImplementation(() => new Promise(resolve => { resolveLogin = resolve; }));
  render(<LoginPage onLoginSuccess={jest.fn()} />);
  fireEvent.change(screen.getByLabelText('Email address'), { target: { value: 'admin@example.test' } });
  fireEvent.change(screen.getByLabelText('Password', {exact:true}), { target: { value: 'test-password' } });
  fireEvent.click(screen.getByRole('button', { name: /Sign In to Console/i }));
  expect(screen.getByRole('button', { name: 'Signing in…' })).toBeDisabled();
  await act(async () => { resolveLogin({data:{user:null}, error:{message:'Invalid login credentials'}}); });
  expect(await screen.findByRole('alert')).toHaveTextContent('Invalid login credentials');
  expect(screen.getByRole('button', {name:/Sign In to Console/i})).toBeEnabled();
});

test('forwards valid credentials and the authenticated user', async () => {
  const user = {id:'test-admin'};
  const onLoginSuccess = jest.fn();
  supabase.auth.signInWithPassword.mockResolvedValue({data:{user},error:null});
  render(<LoginPage onLoginSuccess={onLoginSuccess} />);
  fireEvent.change(screen.getByLabelText('Email address'), {target:{value:'admin@example.test'}});
  fireEvent.change(screen.getByLabelText('Password', {exact:true}), {target:{value:'test-password'}});
  fireEvent.click(screen.getByRole('button', {name:/Sign In to Console/i}));
  await waitFor(() => expect(onLoginSuccess).toHaveBeenCalledWith(user));
  expect(supabase.auth.signInWithPassword).toHaveBeenCalledWith({email:'admin@example.test',password:'test-password'});
});

test('announces Caps Lock and clears the notice when the password field loses focus', () => {
  render(<LoginPage onLoginSuccess={jest.fn()} />);
  const input = screen.getByLabelText('Password', {exact:true});
  const event = new KeyboardEvent('keydown', {key:'A',bubbles:true});
  Object.defineProperty(event, 'getModifierState', {value: key => key === 'CapsLock'});
  fireEvent(input, event);
  expect(screen.getByRole('status')).toHaveTextContent('Caps Lock is on.');
  fireEvent.blur(input);
  expect(screen.queryByText('Caps Lock is on.')).not.toBeInTheDocument();
});
