import { useCallback } from 'react';
import { DEFAULT_ORG_ID } from '../lib/supabase';
import type { User, UserRole } from '../types';

export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: User | null;
  userRole: UserRole;
}

const defaultMockUser: User = {
  id: DEFAULT_ORG_ID,
  email: 'admin@vahanone.com',
  organizationId: DEFAULT_ORG_ID,
  fullName: 'Fleet Administrator',
  role: 'vehicle_owner',
};

export function useAuth(): AuthState & { signOut: () => Promise<void> } {
  const signOut = useCallback(async () => {
    // Auth is bypassed
  }, []);

  return {
    isAuthenticated: true,
    isLoading: false,
    user: defaultMockUser,
    userRole: 'vehicle_owner',
    signOut,
  };
}

export async function signInWithGoogle() {
  return {};
}

export async function signUp(
  email: string,
  password: string,
  fullName: string,
  organizationName: string
) {
  return {};
}

export async function signIn(email: string, password: string) {
  return {};
}

export async function resetPassword(email: string) {
  return {};
}

export async function updatePassword(newPassword: string) {
  return {};
}

export async function updateProfile(updates: {
  fullName?: string;
  phone?: string;
  avatarUrl?: string;
}) {
  return {
    full_name: updates.fullName,
    phone: updates.phone,
    avatar_url: updates.avatarUrl,
  };
}

export function setAuthenticated(value: boolean) {}

export function clearAuth() {}
