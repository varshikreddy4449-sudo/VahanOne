import { useEffect, useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import type { User, UserRole } from '../types';

const AUTH_KEY = 'vahanone_auth';

export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: User | null;
  userRole: UserRole;
}

export function useAuth(): AuthState & { signOut: () => Promise<void> } {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState<User | null>(null);
  const [userRole, setUserRole] = useState<UserRole>('vehicle_owner');

  const fetchUserProfile = useCallback(async (userId: string) => {
    try {
      const { data: profile, error } = await supabase
        .from('user_profiles')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (error) {
        console.error('Error fetching user profile:', error);
        return null;
      }

      return {
        id: profile.user_id,
        email: '',
        organizationId: profile.organization_id,
        fullName: profile.full_name,
        phone: profile.phone,
        avatarUrl: profile.avatar_url,
        role: profile.role || 'vehicle_owner',
      } as User;
    } catch (err) {
      console.error('Error in fetchUserProfile:', err);
      return null;
    }
  }, []);

  const signOut = useCallback(async () => {
    await supabase.auth.signOut();
    localStorage.removeItem(AUTH_KEY);
    setUser(null);
    setIsAuthenticated(false);
  }, []);

  useEffect(() => {
    let mounted = true;

    async function checkSession() {
      try {
        const { data: { session } } = await supabase.auth.getSession();

        if (!mounted) return;

        if (session?.user) {
          const { data: { user: authUser } } = await supabase.auth.getUser();
          if (authUser) {
            const profile = await fetchUserProfile(authUser.id);
            if (profile) {
              setUser({
                ...profile,
                email: authUser.email || '',
              });
              setUserRole(profile.role);
              setIsAuthenticated(true);
              localStorage.setItem(AUTH_KEY, 'true');
            } else {
              setUser({
                id: authUser.id,
                email: authUser.email || '',
                organizationId: '00000000-0000-0000-0000-000000000001',
                role: 'vehicle_owner',
              });
              setUserRole('vehicle_owner');
              setIsAuthenticated(true);
              localStorage.setItem(AUTH_KEY, 'true');
            }
          }
        }
      } catch (err) {
        console.error('Error checking session:', err);
      } finally {
        if (mounted) {
          setIsLoading(false);
        }
      }
    }

    checkSession();

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (!mounted) return;

        if (event === 'SIGNED_IN' && session?.user) {
          const profile = await fetchUserProfile(session.user.id);
          if (profile) {
            setUser({
              ...profile,
              email: session.user.email || '',
            });
            setUserRole(profile.role);
          } else {
            setUser({
              id: session.user.id,
              email: session.user.email || '',
              organizationId: '00000000-0000-0000-0000-000000000001',
              role: 'vehicle_owner',
            });
          }
          setIsAuthenticated(true);
          localStorage.setItem(AUTH_KEY, 'true');
        } else if (event === 'SIGNED_OUT') {
          setUser(null);
          setIsAuthenticated(false);
          localStorage.removeItem(AUTH_KEY);
        } else if (event === 'TOKEN_REFRESHED' && session?.user) {
          const profile = await fetchUserProfile(session.user.id);
          if (profile) {
            setUser({
              ...profile,
              email: session.user.email || '',
            });
            setUserRole(profile.role);
          }
        }
      }
    );

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, [fetchUserProfile]);

  return {
    isAuthenticated,
    isLoading,
    user,
    userRole,
    signOut,
  };
}

export async function signInWithGoogle() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: `${window.location.origin}/auth/callback`,
    },
  });

  if (error) {
    console.error('Error signing in with Google:', error);
    throw error;
  }

  return data;
}

export async function signUp(
  email: string,
  password: string,
  fullName: string,
  organizationName: string
) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
      },
    },
  });

  if (error) {
    console.error('Error signing up:', error);
    throw error;
  }

  return data;
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    console.error('Error signing in:', error);
    throw error;
  }

  localStorage.setItem(AUTH_KEY, 'true');
  return data;
}

export async function resetPassword(email: string) {
  const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${window.location.origin}/reset-password`,
  });

  if (error) {
    console.error('Error resetting password:', error);
    throw error;
  }

  return data;
}

export async function updatePassword(newPassword: string) {
  const { data, error } = await supabase.auth.updateUser({
    password: newPassword,
  });

  if (error) {
    console.error('Error updating password:', error);
    throw error;
  }

  return data;
}

export async function updateProfile(updates: {
  fullName?: string;
  phone?: string;
  avatarUrl?: string;
}) {
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) throw new Error('Not authenticated');

  const { data, error } = await supabase
    .from('user_profiles')
    .update({
      full_name: updates.fullName,
      phone: updates.phone,
      avatar_url: updates.avatarUrl,
    })
    .eq('user_id', user.id)
    .select()
    .single();

  if (error) {
    console.error('Error updating profile:', error);
    throw error;
  }

  return data;
}

export function setAuthenticated(value: boolean) {
  localStorage.setItem(AUTH_KEY, String(value));
  window.dispatchEvent(new Event('storage'));
}

export function clearAuth() {
  localStorage.removeItem(AUTH_KEY);
  window.dispatchEvent(new Event('storage'));
}
