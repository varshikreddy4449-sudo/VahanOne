import { LogOut, Bell } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';

interface HeaderProps {
  unreadCount?: number;
  onNotificationOpen?: () => void;
}

export function Header({ unreadCount, onNotificationOpen }: HeaderProps) {
  const { user, signOut } = useAuth();

  return (
    <header className="mb-6 flex flex-col gap-4 rounded-3xl bg-white p-4 shadow-sm shadow-slate-200/50 sm:flex-row sm:items-center sm:justify-between">
      <div>
        <h1 className="text-lg font-semibold text-slate-900">
          Welcome back, {user?.fullName || user?.email?.split('@')[0] || 'User'}
        </h1>
        <p className="text-sm text-slate-500">Manage your fleet operations and profit analytics.</p>
      </div>
      <div className="flex items-center gap-3">
        {onNotificationOpen && (
          <button
            onClick={onNotificationOpen}
            className="relative flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 bg-white text-slate-600 transition hover:bg-slate-50"
          >
            <Bell className="h-5 w-5" />
            {unreadCount && unreadCount > 0 && (
              <span className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs font-medium text-white">
                {unreadCount > 9 ? '9+' : unreadCount}
              </span>
            )}
          </button>
        )}
        <button
          onClick={signOut}
          className="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-red-50 hover:text-red-700"
        >
          <LogOut className="h-4 w-4" />
          Sign out
        </button>
      </div>
    </header>
  );
}
