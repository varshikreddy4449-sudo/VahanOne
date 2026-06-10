import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapTripRequest, mapTripResponse } from '../lib/transformers';
import type { Trip } from '../types';
import { calculateTripProfit } from './profitService';

export type TripCreatePayload = Omit<Trip, 'id' | 'distanceKm'>;
export type TripUpdatePayload = Partial<Omit<Trip, 'id'>>;

export async function fetchTrips(): Promise<Trip[]> {
  const { data, error } = await supabase
    .from('trips')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('start_time', { ascending: false });

  if (error) {
    console.error('Error fetching trips:', error);
    throw new Error('Failed to fetch trips');
  }

  return (data || []).map(mapTripResponse);
}

export async function fetchTripsByBooking(bookingId: string): Promise<Trip[]> {
  const { data, error } = await supabase
    .from('trips')
    .select('*')
    .eq('booking_id', parseInt(bookingId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('start_time', { ascending: false });

  if (error) {
    console.error('Error fetching trips by booking:', error);
    throw new Error('Failed to fetch trips');
  }

  return (data || []).map(mapTripResponse);
}

export async function fetchTrip(tripId: string): Promise<Trip> {
  const { data, error } = await supabase
    .from('trips')
    .select('*')
    .eq('id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching trip:', error);
    throw new Error('Failed to fetch trip');
  }

  return mapTripResponse(data);
}

export async function createTrip(payload: TripCreatePayload): Promise<Trip> {
  const insertData = {
    ...mapTripRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
    booking_id: parseInt(payload.bookingId, 10),
    vehicle_id: parseInt(payload.vehicleId, 10),
  };

  const { data, error } = await supabase
    .from('trips')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating trip:', error);
    throw new Error('Failed to create trip');
  }

  // Calculate and store trip profit if revenue is provided
  if (payload.revenue && payload.revenue > 0) {
    await calculateTripProfit(String(data.id));
  }

  return mapTripResponse(data);
}

export async function updateTrip(tripId: string, payload: TripUpdatePayload): Promise<Trip> {
  const updateData = mapTripRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('trips')
    .update(updateData)
    .eq('id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating trip:', error);
    throw new Error('Failed to update trip');
  }

  // Recalculate profit if revenue changed
  if (payload.revenue !== undefined) {
    await calculateTripProfit(tripId);
  }

  return mapTripResponse(data);
}

export async function deleteTrip(tripId: string): Promise<void> {
  const { error } = await supabase
    .from('trips')
    .delete()
    .eq('id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting trip:', error);
    throw new Error('Failed to delete trip');
  }
}
