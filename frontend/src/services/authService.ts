import { supabase } from '../lib/supabase';
import { clearAuthStorage, saveTokens } from '../lib/auth';

export interface LoginPayload {
  email: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  refresh_token: string;
  expires_in?: number;
}

export async function login(payload: LoginPayload): Promise<AuthResponse> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email: payload.email,
    password: payload.password,
  });

  if (error) {
    console.error('Login error:', error);
    throw new Error(error.message || 'Failed to login');
  }

  if (!data.session) {
    throw new Error('No session returned');
  }

  // Save tokens to localStorage for compatibility
  saveTokens({
    accessToken: data.session.access_token,
    refreshToken: data.session.refresh_token,
  });

  return {
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_in: data.session.expires_in,
  };
}

export async function signup(payload: { email: string; password: string; name?: string }): Promise<AuthResponse> {
  const { data, error } = await supabase.auth.signUp({
    email: payload.email,
    password: payload.password,
    options: {
      data: {
        name: payload.name,
      },
    },
  });

  if (error) {
    console.error('Signup error:', error);
    throw new Error(error.message || 'Failed to create account');
  }

  if (!data.session) {
    // User might need to confirm email
    throw new Error('Account created. Please check your email to confirm your account.');
  }

  saveTokens({
    accessToken: data.session.access_token,
    refreshToken: data.session.refresh_token,
  });

  return {
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_in: data.session.expires_in,
  };
}

export async function refreshAccessToken(): Promise<AuthResponse> {
  const { data, error } = await supabase.auth.refreshSession();

  if (error) {
    console.error('Token refresh error:', error);
    throw new Error('Failed to refresh session');
  }

  if (!data.session) {
    throw new Error('No session after refresh');
  }

  saveTokens({
    accessToken: data.session.access_token,
    refreshToken: data.session.refresh_token,
  });

  return {
    access_token: data.session.access_token,
    refresh_token: data.session.refresh_token,
    expires_in: data.session.expires_in,
  };
}

export async function logout(): Promise<void> {
  await supabase.auth.signOut();
  clearAuthStorage();
  window.location.href = '/login';
}

export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser();

  if (error) {
    console.error('Get user error:', error);
    return null;
  }

  return data.user;
}

export async function isAuthenticated(): Promise<boolean> {
  const { data } = await supabase.auth.getSession();
  return !!data.session;
}
