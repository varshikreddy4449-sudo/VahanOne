import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import type { Driver } from '../types';

export type DriverCreatePayload = Omit<Driver, 'id'>;
export type DriverUpdatePayload = Partial<Omit<Driver, 'id'>>;

interface DriverRow {
  id: number;
  organization_id: string;
  name: string;
  contact_number: string | null;
  license_number: string;
  license_expiry: string | null;
  deleted_at: string | null;
  created_at: string;
  updated_at: string;
}

function mapDriverResponse(row: DriverRow): Driver {
  return {
    id: String(row.id),
    name: row.name,
    phone: row.contact_number || undefined,
    licenseNumber: row.license_number,
    licenseExpiry: row.license_expiry || undefined,
    status: row.deleted_at ? 'inactive' : 'active',
  };
}

export async function fetchDrivers(): Promise<Driver[]> {
  const { data, error } = await supabase
    .from('drivers')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .is('deleted_at', null)
    .order('name', { ascending: true });

  if (error) {
    console.error('Error fetching drivers:', error);
    throw new Error('Failed to fetch drivers');
  }

  return (data || []).map(mapDriverResponse);
}

export async function createDriver(payload: DriverCreatePayload): Promise<Driver> {
  const insertData = {
    organization_id: DEFAULT_ORG_ID,
    name: payload.name,
    contact_number: payload.phone,
    license_number: payload.licenseNumber,
    license_expiry: payload.licenseExpiry || null,
  };

  const { data, error } = await supabase
    .from('drivers')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating driver:', error);
    throw new Error('Failed to create driver');
  }

  return mapDriverResponse(data);
}

export async function updateDriver(driverId: string, payload: DriverUpdatePayload): Promise<Driver> {
  const updateData: Record<string, unknown> = {};

  if (payload.name !== undefined) updateData.name = payload.name;
  if (payload.phone !== undefined) updateData.contact_number = payload.phone;
  if (payload.licenseNumber !== undefined) updateData.license_number = payload.licenseNumber;
  if (payload.licenseExpiry !== undefined) updateData.license_expiry = payload.licenseExpiry;
  if (payload.status !== undefined) {
    updateData.deleted_at = payload.status === 'inactive' ? new Date().toISOString() : null;
  }

  const { data, error } = await supabase
    .from('drivers')
    .update(updateData)
    .eq('id', parseInt(driverId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating driver:', error);
    throw new Error('Failed to update driver');
  }

  return mapDriverResponse(data);
}

export async function deleteDriver(driverId: string): Promise<void> {
  const { error } = await supabase
    .from('drivers')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', parseInt(driverId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting driver:', error);
    throw new Error('Failed to delete driver');
  }
}
