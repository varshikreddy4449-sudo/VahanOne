import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import type { Reminder, ReminderStatus } from '../types/notifications';

export interface ReminderQueryParams {
  status?: ReminderStatus;
  entityType?: string;
  search?: string;
  limit?: number;
  offset?: number;
}

export async function fetchReminders(params?: ReminderQueryParams): Promise<Reminder[]> {
  let query = supabase
    .from('reminders')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('reminder_date', { ascending: false });

  if (params?.status) {
    query = query.eq('status', params.status);
  }

  if (params?.limit) {
    query = query.limit(params.limit);
  }

  if (params?.offset) {
    query = query.range(params.offset, params.offset + (params.limit || 10) - 1);
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error fetching reminders:', error);
    throw new Error('Failed to fetch reminders');
  }

  let reminders = data || [];

  if (params?.search) {
    const searchLower = params.search.toLowerCase();
    reminders = reminders.filter(r => r.message?.toLowerCase().includes(searchLower));
  }

  return reminders as Reminder[];
}

export async function fetchUnreadCount(): Promise<number> {
  const { count, error } = await supabase
    .from('reminders')
    .select('*', { count: 'exact', head: true })
    .eq('organization_id', DEFAULT_ORG_ID)
    .eq('status', 'pending');

  if (error) {
    console.error('Error fetching unread count:', error);
    return 0;
  }

  return count || 0;
}

export async function markReminderRead(id: number): Promise<Reminder> {
  const { data, error } = await supabase
    .from('reminders')
    .update({ status: 'read' })
    .eq('id', id)
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error marking reminder as read:', error);
    throw new Error('Failed to mark reminder as read');
  }

  return data as Reminder;
}

export async function archiveReminder(id: number): Promise<Reminder> {
  const { data, error } = await supabase
    .from('reminders')
    .update({ status: 'archived' })
    .eq('id', id)
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error archiving reminder:', error);
    throw new Error('Failed to archive reminder');
  }

  return data as Reminder;
}

// Create reminders based on vehicle expiry dates
export async function generateVehicleReminders(): Promise<void> {
  const now = new Date();
  const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  // Fetch vehicles with expiry dates
  const { data: vehicles, error: vehicleError } = await supabase
    .from('vehicles')
    .select('id, vehicle_number, insurance_expiry_date, permit_expiry_date, fc_expiry_date, pollution_expiry_date, road_tax_expiry_date')
    .eq('organization_id', DEFAULT_ORG_ID)
    .is('deleted_at', null);

  if (vehicleError || !vehicles) {
    console.error('Error fetching vehicles for reminders:', vehicleError);
    return;
  }

  const reminderRuleId = 1; // Default rule ID for vehicle compliance reminders

  const newReminders: Array<{
    organization_id: string;
    rule_id: number;
    entity_type: string;
    entity_id: number;
    reminder_date: string;
    due_date: string | null;
    status: string;
    message: string;
  }> = [];

  for (const vehicle of vehicles) {
    const expiryDates = [
      { field: 'insurance_expiry_date', name: 'Insurance', date: vehicle.insurance_expiry_date },
      { field: 'permit_expiry_date', name: 'Permit', date: vehicle.permit_expiry_date },
      { field: 'fc_expiry_date', name: 'FC', date: vehicle.fc_expiry_date },
      { field: 'pollution_expiry_date', name: 'Pollution', date: vehicle.pollution_expiry_date },
      { field: 'road_tax_expiry_date', name: 'Road Tax', date: vehicle.road_tax_expiry_date },
    ];

    for (const item of expiryDates) {
      if (item.date) {
        const expiryDate = new Date(item.date);
        if (expiryDate <= thirtyDaysFromNow) {
          newReminders.push({
            organization_id: DEFAULT_ORG_ID,
            rule_id: reminderRuleId,
            entity_type: 'vehicle',
            entity_id: vehicle.id,
            reminder_date: now.toISOString(),
            due_date: item.date,
            status: 'pending',
            message: `${item.name} expiry for vehicle ${vehicle.vehicle_number} on ${expiryDate.toLocaleDateString()}`,
          });
        }
      }
    }
  }

  if (newReminders.length > 0) {
    // Delete existing pending vehicle reminders first
    await supabase
      .from('reminders')
      .delete()
      .eq('organization_id', DEFAULT_ORG_ID)
      .eq('entity_type', 'vehicle')
      .eq('status', 'pending');

    // Insert new reminders
    const { error: insertError } = await supabase
      .from('reminders')
      .insert(newReminders);

    if (insertError) {
      console.error('Error inserting reminders:', insertError);
    }
  }
}
