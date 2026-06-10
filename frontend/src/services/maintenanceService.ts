import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapMaintenanceRequest, mapMaintenanceResponse } from '../lib/transformers';
import type { MaintenanceSchedule } from '../types';

export type MaintenanceScheduleCreatePayload = Omit<MaintenanceSchedule, 'id'>;
export type MaintenanceScheduleUpdatePayload = Partial<Omit<MaintenanceSchedule, 'id'>>;

export async function fetchMaintenanceSchedules(): Promise<MaintenanceSchedule[]> {
  const { data, error } = await supabase
    .from('maintenance_schedule')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('start_date', { ascending: true });

  if (error) {
    console.error('Error fetching maintenance schedules:', error);
    throw new Error('Failed to fetch maintenance schedules');
  }

  return (data || []).map(mapMaintenanceResponse);
}

export async function createMaintenanceSchedule(payload: MaintenanceScheduleCreatePayload): Promise<MaintenanceSchedule> {
  const insertData = {
    ...mapMaintenanceRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
    vehicle_id: parseInt(payload.vehicleId, 10),
  };

  const { data, error } = await supabase
    .from('maintenance_schedule')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating maintenance schedule:', error);
    throw new Error('Failed to create maintenance schedule');
  }

  // Create a calendar event for the maintenance
  await supabase.from('vehicle_calendar_events').insert({
    organization_id: DEFAULT_ORG_ID,
    vehicle_id: insertData.vehicle_id,
    maintenance_id: data.id,
    title: `Maintenance: ${payload.reason}`,
    event_type: 'maintenance',
    status: 'pending',
    start_date: insertData.start_date,
    end_date: insertData.end_date,
  });

  return mapMaintenanceResponse(data);
}

export async function updateMaintenanceSchedule(maintenanceId: string, payload: MaintenanceScheduleUpdatePayload): Promise<MaintenanceSchedule> {
  const updateData = mapMaintenanceRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('maintenance_schedule')
    .update(updateData)
    .eq('id', parseInt(maintenanceId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating maintenance schedule:', error);
    throw new Error('Failed to update maintenance schedule');
  }

  // Update the calendar event
  const eventData: Record<string, unknown> = {};
  if (updateData.start_date) eventData.start_date = updateData.start_date;
  if (updateData.end_date) eventData.end_date = updateData.end_date;
  if (payload.reason) eventData.title = `Maintenance: ${payload.reason}`;

  if (Object.keys(eventData).length > 0) {
    await supabase
      .from('vehicle_calendar_events')
      .update(eventData)
      .eq('maintenance_id', parseInt(maintenanceId, 10))
      .eq('organization_id', DEFAULT_ORG_ID);
  }

  return mapMaintenanceResponse(data);
}
