import { useEffect, useState } from 'react';

const AUTH_KEY = 'vahanone_auth';

export function useAuth() {
  const [isAuthenticated, setIsAuthenticated] = useState(() => {
    return localStorage.getItem(AUTH_KEY) === 'true';
  });
  const [accessToken, setAccessToken] = useState<string | null>(() => {
    return localStorage.getItem(AUTH_KEY) === 'true' ? 'local-session' : null;
  });

  useEffect(() => {
    const handler = () => {
      const authed = localStorage.getItem(AUTH_KEY) === 'true';
      setIsAuthenticated(authed);
      setAccessToken(authed ? 'local-session' : null);
    };
    window.addEventListener('storage', handler);
    return () => window.removeEventListener('storage', handler);
  }, []);

  return {
    isAuthenticated,
    isLoading: false,
    accessToken,
  };
}

export function setAuthenticated(value: boolean) {
  localStorage.setItem(AUTH_KEY, String(value));
  window.dispatchEvent(new Event('storage'));
}

export function clearAuth() {
  localStorage.removeItem(AUTH_KEY);
  window.dispatchEvent(new Event('storage'));
}
