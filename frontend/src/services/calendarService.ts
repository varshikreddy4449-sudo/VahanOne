import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapCalendarEventResponse } from '../lib/transformers';
import type { CalendarEvent } from '../types';

export async function fetchCalendarEvents(params?: { startDate?: string; endDate?: string; vehicleId?: string }): Promise<CalendarEvent[]> {
  let query = supabase
    .from('vehicle_calendar_events')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID);

  if (params?.startDate) {
    query = query.gte('start_date', params.startDate);
  }
  if (params?.endDate) {
    query = query.lte('end_date', params.endDate);
  }
  if (params?.vehicleId) {
    query = query.eq('vehicle_id', parseInt(params.vehicleId, 10));
  }

  const { data, error } = await query.order('start_date', { ascending: true });

  if (error) {
    console.error('Error fetching calendar events:', error);
    throw new Error('Failed to fetch calendar events');
  }

  return (data || []).map(mapCalendarEventResponse);
}
