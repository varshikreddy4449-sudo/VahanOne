import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapVehicleRequest, mapVehicleResponse, mapVehicleAvailabilityResponse } from '../lib/transformers';
import type { Vehicle, VehicleAvailability } from '../types';

export type VehicleCreatePayload = Omit<Vehicle, 'id'>;
export type VehicleUpdatePayload = Partial<Omit<Vehicle, 'id'>>;

export async function fetchVehicles(): Promise<Vehicle[]> {
  const { data, error } = await supabase
    .from('vehicles')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .is('deleted_at', null)
    .order('id', { ascending: true });

  if (error) {
    console.error('Error fetching vehicles:', error);
    throw new Error('Failed to fetch vehicles');
  }

  return (data || []).map(mapVehicleResponse);
}

export async function fetchVehicle(vehicleId: string): Promise<Vehicle> {
  const { data, error } = await supabase
    .from('vehicles')
    .select('*')
    .eq('id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching vehicle:', error);
    throw new Error('Failed to fetch vehicle');
  }

  return mapVehicleResponse(data);
}

export async function createVehicle(payload: VehicleCreatePayload): Promise<Vehicle> {
  const insertData = {
    ...mapVehicleRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
  };

  const { data, error } = await supabase
    .from('vehicles')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating vehicle:', error);
    throw new Error('Failed to create vehicle');
  }

  return mapVehicleResponse(data);
}

export async function updateVehicle(vehicleId: string, payload: VehicleUpdatePayload): Promise<Vehicle> {
  const updateData = mapVehicleRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('vehicles')
    .update(updateData)
    .eq('id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating vehicle:', error);
    throw new Error('Failed to update vehicle');
  }

  return mapVehicleResponse(data);
}

export async function deleteVehicle(vehicleId: string): Promise<void> {
  const { error } = await supabase
    .from('vehicles')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting vehicle:', error);
    throw new Error('Failed to delete vehicle');
  }
}

export async function fetchVehicleAvailability(
  vehicleId: string,
  startDate: string,
  endDate: string,
): Promise<VehicleAvailability> {
  const start = new Date(startDate);
  const end = new Date(endDate);

  // Check for overlapping bookings
  const { data: bookings, error: bookingError } = await supabase
    .from('bookings')
    .select('id, start_date, end_date, status')
    .eq('vehicle_id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .neq('status', 'cancelled')
    .or(`start_date.lte.${end.toISOString()},end_date.gte.${start.toISOString()}`);

  if (bookingError) {
    console.error('Error checking booking availability:', bookingError);
    throw new Error('Failed to check vehicle availability');
  }

  // Check for overlapping maintenance
  const { data: maintenance, error: maintenanceError } = await supabase
    .from('maintenance_schedule')
    .select('id, start_date, end_date, status')
    .eq('vehicle_id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .neq('status', 'cancelled')
    .or(`start_date.lte.${end.toISOString()},end_date.gte.${start.toISOString()}`);

  if (maintenanceError) {
    console.error('Error checking maintenance availability:', maintenanceError);
    throw new Error('Failed to check vehicle availability');
  }

  const hasBookingConflict = bookings && bookings.length > 0;
  const hasMaintenanceConflict = maintenance && maintenance.length > 0;

  let available = true;
  let reason: string | undefined;

  if (hasBookingConflict) {
    available = false;
    reason = 'Vehicle has overlapping bookings during this period';
  } else if (hasMaintenanceConflict) {
    available = false;
    reason = 'Vehicle is scheduled for maintenance during this period';
  }

  return {
    vehicleId,
    startDate,
    endDate,
    available,
    reason,
  };
}
