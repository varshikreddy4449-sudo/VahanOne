import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import { Loader as Loader2 } from 'lucide-react';

export function AuthCallback() {
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    async function handleCallback() {
      try {
        const { data: { session }, error: sessionError } = await supabase.auth.getSession();

        if (sessionError) {
          throw sessionError;
        }

        if (session?.user) {
          const { data: existingProfile } = await supabase
            .from('user_profiles')
            .select('*')
            .eq('user_id', session.user.id)
            .single();

          if (!existingProfile) {
            const orgId = session.user.user_metadata?.organization_id || '00000000-0000-0000-0000-000000000001';

            await supabase.from('user_profiles').insert({
              user_id: session.user.id,
              organization_id: orgId,
              full_name: session.user.user_metadata?.full_name || session.user.user_metadata?.name,
              email: session.user.email,
              role: 'fleet_owner',
            });
          }

          navigate('/dashboard', { replace: true });
        } else {
          navigate('/login', { replace: true });
        }
      } catch (err) {
        console.error('Auth callback error:', err);
        setError(err instanceof Error ? err.message : 'Authentication failed');
        setTimeout(() => navigate('/login'), 3000);
      }
    }

    handleCallback();
  }, [navigate]);

  if (error) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-slate-50">
        <div className="text-center">
          <div className="mb-4 flex justify-center">
            <div className="flex h-16 w-16 items-center justify-center rounded-full bg-red-100">
              <span className="text-2xl text-red-600">!</span>
            </div>
          </div>
          <h1 className="text-xl font-semibold text-slate-900">Authentication Error</h1>
          <p className="mt-2 text-sm text-slate-600">{error}</p>
          <p className="mt-1 text-sm text-slate-400">Redirecting to login...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100">
      <div className="text-center">
        <Loader2 className="mx-auto h-8 w-8 animate-spin text-primary-600" />
        <p className="mt-4 text-sm text-slate-600">Completing sign in...</p>
      </div>
    </div>
  );
}
