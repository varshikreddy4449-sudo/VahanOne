import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapBookingRequest, mapBookingResponse } from '../lib/transformers';
import type { Booking } from '../types';

export type BookingCreatePayload = Omit<Booking, 'id' | 'status'> & {
  status?: string;
};
export type BookingUpdatePayload = Partial<Omit<Booking, 'id'>>;

export async function fetchBookings(): Promise<Booking[]> {
  const { data, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('start_date', { ascending: false });

  if (error) {
    console.error('Error fetching bookings:', error);
    throw new Error('Failed to fetch bookings');
  }

  return (data || []).map(mapBookingResponse);
}

export async function fetchBooking(bookingId: string): Promise<Booking> {
  const { data, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('id', parseInt(bookingId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching booking:', error);
    throw new Error('Failed to fetch booking');
  }

  return mapBookingResponse(data);
}

export async function createBooking(payload: BookingCreatePayload): Promise<Booking> {
  const insertData = {
    ...mapBookingRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
    status: payload.status || 'pending',
  };

  const { data, error } = await supabase
    .from('bookings')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating booking:', error);
    throw new Error('Failed to create booking');
  }

  // Create a calendar event for the booking
  await supabase.from('vehicle_calendar_events').insert({
    organization_id: DEFAULT_ORG_ID,
    vehicle_id: parseInt(insertData.vehicle_id as string, 10),
    booking_id: data.id,
    title: `Booking: ${payload.pickupLocation} to ${payload.destination}`,
    event_type: 'booking',
    status: 'pending',
    start_date: insertData.start_date,
    end_date: insertData.end_date,
  });

  return mapBookingResponse(data);
}

export async function updateBooking(bookingId: string, payload: BookingUpdatePayload): Promise<Booking> {
  const updateData = mapBookingRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('bookings')
    .update(updateData)
    .eq('id', parseInt(bookingId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating booking:', error);
    throw new Error('Failed to update booking');
  }

  // Update the calendar event if dates or vehicle changed
  if (updateData.start_date || updateData.end_date || updateData.vehicle_id) {
    const eventData: Record<string, unknown> = {};
    if (updateData.start_date) eventData.start_date = updateData.start_date;
    if (updateData.end_date) eventData.end_date = updateData.end_date;
    if (updateData.vehicle_id) eventData.vehicle_id = updateData.vehicle_id;

    await supabase
      .from('vehicle_calendar_events')
      .update(eventData)
      .eq('booking_id', parseInt(bookingId, 10))
      .eq('organization_id', DEFAULT_ORG_ID);
  }

  return mapBookingResponse(data);
}

export async function deleteBooking(bookingId: string): Promise<void> {
  // Calendar events will be deleted by CASCADE
  const { error } = await supabase
    .from('bookings')
    .delete()
    .eq('id', parseInt(bookingId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting booking:', error);
    throw new Error('Failed to delete booking');
  }
}
