import { useEffect, useMemo, useState } from 'react';
import { Plus, Search, ListFilter as Filter, CreditCard as Edit3, Trash2, Phone, CircleAlert as AlertCircle } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { DriverForm } from '../components/drivers/DriverForm';
import { fetchDrivers, createDriver, updateDriver, deleteDriver } from '../services/driverService';
import type { Driver } from '../types';

const statuses = [
  { label: 'All Drivers', value: 'all' },
  { label: 'Active', value: 'active' },
  { label: 'Inactive', value: 'inactive' },
];

function getLicenseExpiryState(dateString: string | undefined) {
  if (!dateString) return 'missing';
  const expiry = new Date(dateString);
  const now = new Date();
  const diffDays = Math.ceil((expiry.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

  if (diffDays < 0) return 'expired';
  if (diffDays <= 30) return 'warning';
  return 'valid';
}

export function Drivers() {
  const [drivers, setDrivers] = useState<Driver[]>([]);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [activeDriver, setActiveDriver] = useState<Driver | undefined>(undefined);

  useEffect(() => {
    async function loadDrivers() {
      setLoading(true);
      setError('');
      try {
        const data = await fetchDrivers();
        setDrivers(data);
      } catch (err) {
        setError('Unable to load drivers. Please try again later.');
      } finally {
        setLoading(false);
      }
    }

    loadDrivers();
  }, []);

  const filteredDrivers = useMemo(() => {
    const normalized = search.toLowerCase().trim();
    return drivers
      .filter((driver) => statusFilter === 'all' || driver.status === statusFilter)
      .filter((driver) =>
        [driver.name, driver.licenseNumber, driver.phone]
          .filter(Boolean)
          .join(' ')
          .toLowerCase()
          .includes(normalized),
      );
  }, [drivers, search, statusFilter]);

  async function refreshDrivers() {
    setLoading(true);
    setError('');
    try {
      const data = await fetchDrivers();
      setDrivers(data);
    } catch {
      setError('Unable to refresh drivers.');
    } finally {
      setLoading(false);
    }
  }

  async function handleSave(payload: Omit<Driver, 'id'>) {
    if (activeDriver) {
      await updateDriver(activeDriver.id, payload);
    } else {
      await createDriver(payload);
    }
    await refreshDrivers();
  }

  async function handleDelete(driverId: string) {
    const confirmed = window.confirm('Remove this driver? This action will soft delete the driver.');
    if (!confirmed) return;

    setLoading(true);
    setError('');
    try {
      await deleteDriver(driverId);
      await refreshDrivers();
    } catch {
      setError('Unable to remove this driver.');
      setLoading(false);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-4 rounded-3xl bg-white p-6 shadow-sm shadow-slate-200/80 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-slate-900">Drivers</h1>
          <p className="mt-1 text-sm text-slate-600">Manage your drivers and their license information.</p>
        </div>
        <Button
          onClick={() => {
            setActiveDriver(undefined);
            setModalOpen(true);
          }}
          className="bg-primary-600 hover:bg-primary-700"
        >
          <Plus className="mr-2 h-4 w-4" />
          Add Driver
        </Button>
      </div>

      <Card>
        <div className="mb-6 grid gap-4 md:grid-cols-[1fr_auto] md:items-center">
          <div className="relative max-w-sm">
            <Search className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400" />
            <Input
              className="pl-11"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search drivers"
            />
          </div>
          <div className="flex flex-wrap items-center gap-3">
            <div className="inline-flex items-center gap-2 rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700">
              <Filter className="h-4 w-4 text-slate-500" />
              <select
                className="appearance-none bg-transparent outline-none"
                value={statusFilter}
                onChange={(event) => setStatusFilter(event.target.value as 'all' | 'active' | 'inactive')}
              >
                {statuses.map((item) => (
                  <option key={item.value} value={item.value}>
                    {item.label}
                  </option>
                ))}
              </select>
            </div>
            <div className="text-sm text-slate-500">
              {loading ? 'Loading drivers…' : `${filteredDrivers.length} drivers`}
            </div>
          </div>
        </div>

        {error && (
          <div className="mb-6 rounded-3xl bg-red-50 px-4 py-3 text-sm text-red-700">
            {error}
          </div>
        )}

        {loading ? (
          <div className="rounded-3xl border border-slate-200 bg-slate-50 p-10 text-center text-slate-500">
            Loading drivers...
          </div>
        ) : filteredDrivers.length === 0 ? (
          <div className="rounded-3xl border border-dashed border-slate-200 bg-slate-50 p-10 text-center text-slate-500">
            <p className="mb-3 text-lg font-semibold text-slate-900">No drivers found</p>
            <p>Use the Add Driver button to create a new driver or update your search filters.</p>
          </div>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {filteredDrivers.map((driver) => {
              const licenseState = getLicenseExpiryState(driver.licenseExpiry);
              const licenseStateClass =
                licenseState === 'expired'
                  ? 'bg-red-100 text-red-700 border-red-200'
                  : licenseState === 'warning'
                  ? 'bg-amber-100 text-amber-700 border-amber-200'
                  : licenseState === 'valid'
                  ? 'bg-emerald-100 text-emerald-700 border-emerald-200'
                  : 'bg-slate-100 text-slate-500 border-slate-200';

              return (
                <div key={driver.id} className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <h3 className="font-semibold text-slate-900">{driver.name}</h3>
                      <div className="mt-1 flex items-center gap-2 text-sm text-slate-500">
                        <span className="font-mono">{driver.licenseNumber}</span>
                        {licenseState !== 'missing' && (
                          <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${licenseStateClass}`}>
                            {licenseState === 'expired' ? 'Expired' : licenseState === 'warning' ? 'Expiring Soon' : 'Valid'}
                          </span>
                        )}
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        onClick={() => {
                          setActiveDriver(driver);
                          setModalOpen(true);
                        }}
                      >
                        <Edit3 className="h-4 w-4" />
                      </Button>
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        className="text-red-600 hover:bg-red-50"
                        onClick={() => handleDelete(driver.id)}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                  {driver.phone && (
                    <div className="mt-3 flex items-center gap-2 text-sm text-slate-600">
                      <Phone className="h-4 w-4 text-slate-400" />
                      <a href={`tel:${driver.phone}`} className="hover:text-primary-600">
                        {driver.phone}
                      </a>
                    </div>
                  )}
                  {driver.licenseExpiry && (
                    <div className="mt-2 text-xs text-slate-500">
                      License expires: {new Date(driver.licenseExpiry).toLocaleDateString()}
                    </div>
                  )}
                  <div className="mt-3 flex items-center justify-between">
                    <span className={`inline-flex rounded-full px-2 py-1 text-xs font-semibold ${driver.status === 'active' ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-600'}`}>
                      {driver.status === 'active' ? 'Active' : 'Inactive'}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </Card>

      <DriverForm
        open={modalOpen}
        driver={activeDriver}
        onClose={() => setModalOpen(false)}
        onSave={handleSave}
      />
    </div>
  );
}
