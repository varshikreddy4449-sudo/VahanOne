import { useEffect, useState } from 'react';
import { Button } from '../../components/ui/Button';
import { Input } from '../../components/ui/Input';
import { getApiErrorMessage } from '../../lib/api';
import type { Vehicle } from '../../types';

interface VehicleFormProps {
  open: boolean;
  vehicle?: Vehicle;
  onClose: () => void;
  onSave: (payload: Omit<Vehicle, 'id'>) => Promise<void>;
}

export function VehicleForm({ open, vehicle, onClose, onSave }: VehicleFormProps) {
  const [vehicleNumber, setVehicleNumber] = useState('');
  const [vehicleType, setVehicleType] = useState('');
  const [make, setMake] = useState('');
  const [model, setModel] = useState('');
  const [year, setYear] = useState<number | ''>('');
  const [seatingCapacity, setSeatingCapacity] = useState<number | ''>('');
  const [fuelType, setFuelType] = useState('Diesel');
  const [chassisNumber, setChassisNumber] = useState('');
  const [engineNumber, setEngineNumber] = useState('');
  const [rcExpiry, setRcExpiry] = useState('');
  const [insuranceExpiry, setInsuranceExpiry] = useState('');
  const [permitExpiry, setPermitExpiry] = useState('');
  const [fcExpiry, setFcExpiry] = useState('');
  const [pollutionExpiry, setPollutionExpiry] = useState('');
  const [roadTaxExpiry, setRoadTaxExpiry] = useState('');
  const [emiAmount, setEmiAmount] = useState<number | ''>('');
  const [emiDueDay, setEmiDueDay] = useState<number | ''>('');
  const [status, setStatus] = useState<'active' | 'inactive'>('active');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (vehicle) {
      setVehicleNumber(vehicle.licensePlate);
      setVehicleType(vehicle.vehicleType || '');
      setMake(vehicle.make);
      setModel(vehicle.model);
      setYear(vehicle.year || '');
      setSeatingCapacity(vehicle.seatingCapacity ?? '');
      setFuelType(vehicle.fuelType || 'Diesel');
      setChassisNumber(vehicle.chassisNumber || '');
      setEngineNumber(vehicle.engineNumber || '');
      setRcExpiry(vehicle.rcExpiry || '');
      setInsuranceExpiry(vehicle.insuranceExpiry || '');
      setPermitExpiry(vehicle.permitExpiry || '');
      setFcExpiry(vehicle.fcExpiry || '');
      setPollutionExpiry(vehicle.pollutionExpiry || '');
      setRoadTaxExpiry(vehicle.roadTaxExpiry || '');
      setEmiAmount(vehicle.emiAmount ?? '');
      setEmiDueDay(vehicle.emiDueDay ?? '');
      setStatus(vehicle.status === 'inactive' ? 'inactive' : 'active');
      setError('');
    } else {
      setVehicleNumber('');
      setVehicleType('');
      setMake('');
      setModel('');
      setYear('');
      setSeatingCapacity('');
      setFuelType('Diesel');
      setChassisNumber('');
      setEngineNumber('');
      setRcExpiry('');
      setInsuranceExpiry('');
      setPermitExpiry('');
      setFcExpiry('');
      setPollutionExpiry('');
      setRoadTaxExpiry('');
      setEmiAmount('');
      setEmiDueDay('');
      setStatus('active');
      setError('');
    }
  }, [vehicle, open]);

  async function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError('');
    setSubmitting(true);

    const trimmedVehicleNumber = vehicleNumber.trim();
    if (!trimmedVehicleNumber) {
      setError('Vehicle number is required.');
      setSubmitting(false);
      return;
    }

    try {
      await onSave({
        licensePlate: trimmedVehicleNumber,
        vehicleType: vehicleType.trim(),
        make: make.trim(),
        model: model.trim(),
        year: year ? Number(year) : undefined,
        seatingCapacity: seatingCapacity ? Number(seatingCapacity) : 0,
        fuelType: fuelType.trim(),
        chassisNumber: chassisNumber.trim() || undefined,
        engineNumber: engineNumber.trim() || undefined,
        rcExpiry: rcExpiry || undefined,
        insuranceExpiry,
        permitExpiry,
        fcExpiry,
        pollutionExpiry,
        roadTaxExpiry,
        emiAmount: emiAmount ? Number(emiAmount) : 0,
        emiDueDay: emiDueDay ? Number(emiDueDay) : 0,
        status,
      });
      onClose();
    } catch (err) {
      setError(getApiErrorMessage(err, 'Unable to save vehicle. Please review the form and try again.'));
    } finally {
      setSubmitting(false);
    }
  }

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-slate-950/40 px-4 py-6">
      <div className="w-full max-w-4xl max-h-[90vh] overflow-y-auto rounded-3xl bg-white p-6 shadow-2xl shadow-slate-900/10">
        <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-xl font-semibold text-slate-900">
              {vehicle ? 'Edit Vehicle' : 'Add Vehicle'}
            </h2>
            <p className="text-sm text-slate-500">
              Enter vehicle details and compliance dates. Vehicle number is required.
            </p>
          </div>
          <Button type="button" variant="ghost" onClick={onClose}>
            Close
          </Button>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="rounded-2xl border border-slate-200 p-4">
            <h3 className="mb-4 text-sm font-semibold text-slate-700">Basic Information</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Vehicle Number *</span>
                <Input value={vehicleNumber} onChange={(e) => setVehicleNumber(e.target.value.toUpperCase())} required placeholder="MH 01 AB 1234" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Vehicle Type</span>
                <select className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-950 shadow-sm focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-100" value={vehicleType} onChange={(e) => setVehicleType(e.target.value)}>
                  <option value="">Select type</option>
                  <option value="Truck">Truck</option>
                  <option value="Bus">Bus</option>
                  <option value="Mini Bus">Mini Bus</option>
                  <option value="Tempo">Tempo</option>
                  <option value="Van">Van</option>
                  <option value="Car">Car</option>
                  <option value="Trailer">Trailer</option>
                  <option value="Container">Container</option>
                </select>
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Make</span>
                <Input value={make} onChange={(e) => setMake(e.target.value)} placeholder="Tata, Ashok Leyland, etc." />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Model</span>
                <Input value={model} onChange={(e) => setModel(e.target.value)} placeholder="Model name" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Year</span>
                <Input value={year} onChange={(e) => setYear(e.target.value ? Number(e.target.value) : '')} type="number" min={1990} max={2030} placeholder="2024" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Seating Capacity</span>
                <Input value={seatingCapacity} onChange={(e) => setSeatingCapacity(e.target.value ? Number(e.target.value) : '')} type="number" min={1} placeholder="e.g., 40" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Fuel Type</span>
                <select className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-950 shadow-sm focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-100" value={fuelType} onChange={(e) => setFuelType(e.target.value)}>
                  <option>Diesel</option>
                  <option>Petrol</option>
                  <option>CNG</option>
                  <option>Electric</option>
                  <option>Hybrid</option>
                </select>
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Status</span>
                <select className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 text-sm text-slate-950 shadow-sm focus:border-primary-400 focus:outline-none focus:ring-2 focus:ring-primary-100" value={status} onChange={(e) => setStatus(e.target.value as 'active' | 'inactive')}>
                  <option value="active">Active</option>
                  <option value="inactive">Inactive</option>
                </select>
              </label>
            </div>
          </div>

          <div className="rounded-2xl border border-slate-200 p-4">
            <h3 className="mb-4 text-sm font-semibold text-slate-700">Vehicle Identification</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Chassis Number</span>
                <Input value={chassisNumber} onChange={(e) => setChassisNumber(e.target.value)} placeholder="Chassis number" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Engine Number</span>
                <Input value={engineNumber} onChange={(e) => setEngineNumber(e.target.value)} placeholder="Engine number" />
              </label>
            </div>
          </div>

          <div className="rounded-2xl border border-slate-200 p-4">
            <h3 className="mb-4 text-sm font-semibold text-slate-700">Compliance & Expiry Dates</h3>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">RC Expiry</span>
                <Input value={rcExpiry} onChange={(e) => setRcExpiry(e.target.value)} type="date" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Insurance Expiry</span>
                <Input value={insuranceExpiry} onChange={(e) => setInsuranceExpiry(e.target.value)} type="date" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Permit Expiry</span>
                <Input value={permitExpiry} onChange={(e) => setPermitExpiry(e.target.value)} type="date" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Fitness Certificate Expiry</span>
                <Input value={fcExpiry} onChange={(e) => setFcExpiry(e.target.value)} type="date" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Pollution Expiry</span>
                <Input value={pollutionExpiry} onChange={(e) => setPollutionExpiry(e.target.value)} type="date" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Road Tax Expiry</span>
                <Input value={roadTaxExpiry} onChange={(e) => setRoadTaxExpiry(e.target.value)} type="date" />
              </label>
            </div>
          </div>

          <div className="rounded-2xl border border-slate-200 p-4">
            <h3 className="mb-4 text-sm font-semibold text-slate-700">Financial Details</h3>
            <div className="grid gap-4 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">EMI Amount (₹)</span>
                <Input value={emiAmount} onChange={(e) => setEmiAmount(e.target.value ? Number(e.target.value) : '')} type="number" min={0} placeholder="Monthly EMI" />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">EMI Due Day</span>
                <Input value={emiDueDay} onChange={(e) => setEmiDueDay(e.target.value ? Number(e.target.value) : '')} type="number" min={1} max={31} placeholder="Day of month (1-31)" />
              </label>
            </div>
          </div>

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
              {submitting ? 'Saving...' : vehicle ? 'Update vehicle' : 'Add vehicle'}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
}
