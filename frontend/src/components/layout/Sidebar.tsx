import { useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { Hop as Home, Truck, CalendarDays, MapPin, ChartBar as BarChart3, FileText, DollarSign, ShieldCheck, Flag, Wrench, Users, Settings, Menu, X, LogOut, ChevronRight } from 'lucide-react';
import { useAuth } from '../../hooks/useAuth';

const navItems = [
  { label: 'Dashboard', to: '/dashboard', icon: Home },
  { label: 'Vehicles', to: '/vehicles', icon: Truck },
  { label: 'Drivers', to: '/drivers', icon: Users },
  { label: 'Bookings', to: '/bookings', icon: CalendarDays },
  { label: 'Calendar', to: '/calendar', icon: MapPin },
  { label: 'Dispatch', to: '/dispatch', icon: Flag },
  { label: 'Maintenance', to: '/maintenance', icon: Wrench },
  { label: 'Expenses', to: '/expenses', icon: FileText },
  { label: 'Profit', to: '/profit', icon: DollarSign },
  { label: 'Invoices', to: '/invoices', icon: BarChart3 },
  { label: 'Renewals', to: '/renewals', icon: ShieldCheck },
  { label: 'Settings', to: '/settings', icon: Settings },
];

export function Sidebar() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const { user, signOut } = useAuth();
  const location = useLocation();

  function closeMobile() {
    setMobileOpen(false);
  }

  function handleSignOut() {
    signOut();
    setMobileOpen(false);
  }

  return (
    <>
      <button
        onClick={() => setMobileOpen(true)}
        className="fixed left-4 top-4 z-40 flex h-12 w-12 items-center justify-center rounded-xl bg-primary-600 text-white shadow-lg lg:hidden"
      >
        <Menu className="h-6 w-6" />
      </button>

      {mobileOpen && (
        <div
          className="fixed inset-0 z-40 bg-slate-900/50 lg:hidden"
          onClick={closeMobile}
        />
      )}

      <aside
        className={`
          fixed inset-y-0 left-0 z-50 w-72 transform bg-white shadow-xl transition-transform duration-300 ease-in-out lg:relative lg:left-0 lg:z-auto lg:block lg:transform-none lg:shadow-none lg:border-r lg:border-slate-200
          ${mobileOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
        `}
      >
        <div className="flex h-full flex-col">
          <div className="flex items-center justify-between border-b border-slate-200 p-6">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary-600">
                <span className="text-lg font-bold text-white">V</span>
              </div>
              <div>
                <div className="text-xl font-semibold text-slate-900">VahanOne</div>
                <div className="text-xs text-slate-500">Fleet Management</div>
              </div>
            </div>
            <button
              onClick={closeMobile}
              className="flex h-8 w-8 items-center justify-center rounded-lg text-slate-400 hover:bg-slate-100 lg:hidden"
            >
              <X className="h-5 w-5" />
            </button>
          </div>

          <nav className="flex-1 overflow-y-auto p-4">
            <div className="space-y-1">
              {navItems.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.to;
                return (
                  <NavLink
                    key={item.to}
                    to={item.to}
                    onClick={closeMobile}
                    className={`
                      flex items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium transition-all
                      ${isActive
                        ? 'bg-primary-50 text-primary-700'
                        : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'
                      }
                    `}
                  >
                    <Icon className="h-5 w-5" />
                    <span className="flex-1">{item.label}</span>
                    {isActive && <ChevronRight className="h-4 w-4 text-primary-400" />}
                  </NavLink>
                );
              })}
            </div>
          </nav>

          <div className="border-t border-slate-200 p-4">
            {user && (
              <div className="mb-3 rounded-xl bg-primary-50 p-3">
                <div className="text-sm font-medium text-slate-900">
                  {user.fullName || user.email?.split('@')[0]}
                </div>
                <div className="text-xs text-slate-500">{user.email}</div>
                <div className="mt-1 inline-flex items-center rounded-full bg-primary-100 px-2 py-0.5 text-xs font-medium text-primary-700">
                  {user.role?.replace('_', ' ').replace(/\b\w/g, (l) => l.toUpperCase())}
                </div>
              </div>
            )}
            <button
              onClick={handleSignOut}
              className="flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm font-medium text-slate-600 transition-colors hover:bg-red-50 hover:text-red-700"
            >
              <LogOut className="h-5 w-5" />
              Sign out
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
