import { useEffect, useState } from 'react';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { getApiErrorMessage } from '../../lib/api';
import type { Driver } from '../../types';

interface DriverFormProps {
  open: boolean;
  driver?: Driver;
  onClose: () => void;
  onSave: (payload: Omit<Driver, 'id'>) => Promise<void>;
}

export function DriverForm({ open, driver, onClose, onSave }: DriverFormProps) {
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [licenseNumber, setLicenseNumber] = useState('');
  const [licenseExpiry, setLicenseExpiry] = useState('');
  const [assignedVehicleId, setAssignedVehicleId] = useState('');
  const [status, setStatus] = useState<'active' | 'inactive'>('active');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (driver) {
      setName(driver.name);
      setPhone(driver.phone || '');
      setLicenseNumber(driver.licenseNumber);
      setLicenseExpiry(driver.licenseExpiry || '');
      setAssignedVehicleId(driver.assignedVehicleId || '');
      setStatus(driver.status === 'inactive' ? 'inactive' : 'active');
      setError('');
    } else {
      setName('');
      setPhone('');
      setLicenseNumber('');
      setLicenseExpiry('');
      setAssignedVehicleId('');
      setStatus('active');
      setError('');
    }
  }, [driver, open]);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSubmitting(true);

    const trimmedName = name.trim();
    const trimmedLicense = licenseNumber.trim();

    if (!trimmedName) {
      setError('Driver name is required.');
      setSubmitting(false);
      return;
    }

    if (!trimmedLicense) {
      setError('License number is required.');
      setSubmitting(false);
      return;
    }

    try {
      await onSave({
        name: trimmedName,
        phone: phone.trim(),
        licenseNumber: trimmedLicense,
        licenseExpiry,
        assignedVehicleId: assignedVehicleId || undefined,
        status,
      });
      onClose();
    } catch (err) {
      setError(getApiErrorMessage(err, 'Unable to save driver. Please try again.'));
    } finally {
      setSubmitting(false);
    }
  }

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-slate-950/40 px-4 py-6">
      <div className="w-full max-w-lg max-h-[90vh] overflow-y-auto rounded-3xl bg-white p-6 shadow-2xl shadow-slate-900/10">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-semibold text-slate-900">
              {driver ? 'Edit Driver' : 'Add Driver'}
            </h2>
            <p className="text-sm text-slate-500">
              Enter driver details. Name and license number are required.
            </p>
          </div>
          <Button type="button" variant="ghost" onClick={onClose}>
            Close
          </Button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <label className="space-y-2">
            <span className="text-sm font-medium text-slate-700">Full Name *</span>
            <Input value={name} onChange={(e) => setName(e.target.value)} required placeholder="Driver name" />
          </label>
          <label className="space-y-2">
            <span className="text-sm font-medium text-slate-700">Phone Number</span>
            <Input value={phone} onChange={(e) => setPhone(e.target.value)} type="tel" placeholder="Contact number" />
          </label>
          <label className="space-y-2">
            <span className="text-sm font-medium text-slate-700">License Number *</span>
            <Input value={licenseNumber} onChange={(e) => setLicenseNumber(e.target.value.toUpperCase())} required placeholder="DL number" />
          </label>
          <label className="space-y-2">
            <span className="text-sm font-medium text-slate-700">License Expiry</span>
            <Input value={licenseExpiry} onChange={(e) => setLicenseExpiry(e.target.value)} type="date" />
          </label>
          <label className="space-y-2">
            <span className="text-sm font-medium text-slate-700">Status</span>
            <select className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-950 shadow-sm focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-100" value={status} onChange={(e) => setStatus(e.target.value as 'active' | 'inactive')}>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </label>

          {error && (
            <div className="rounded-2xl bg-red-50 px-4 py-3 text-sm text-red-700">
              {error}
            </div>
          )}

          <div className="flex flex-col gap-3 sm:flex-row sm:justify-end">
            <Button type="button" variant="secondary" onClick={onClose}>
              Cancel
            </Button>
            <Button type="submit" className="bg-primary-600 hover:bg-primary-700" disabled={submitting}>
              {submitting ? 'Saving...' : driver ? 'Update driver' : 'Add driver'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
