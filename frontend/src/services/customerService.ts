import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapCustomerRequest, mapCustomerResponse } from '../lib/transformers';
import type { Customer } from '../types';

export type CustomerCreatePayload = Omit<Customer, 'id'>;
export type CustomerUpdatePayload = Partial<Omit<Customer, 'id'>>;

export async function fetchCustomers(): Promise<Customer[]> {
  const { data, error } = await supabase
    .from('customers')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .is('deleted_at', null)
    .order('id', { ascending: true });

  if (error) {
    console.error('Error fetching customers:', error);
    throw new Error('Failed to fetch customers');
  }

  return (data || []).map(mapCustomerResponse);
}

export async function fetchCustomer(customerId: string): Promise<Customer> {
  const { data, error } = await supabase
    .from('customers')
    .select('*')
    .eq('id', parseInt(customerId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching customer:', error);
    throw new Error('Failed to fetch customer');
  }

  return mapCustomerResponse(data);
}

export async function createCustomer(payload: CustomerCreatePayload): Promise<Customer> {
  const insertData = {
    ...mapCustomerRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
  };

  const { data, error } = await supabase
    .from('customers')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating customer:', error);
    throw new Error('Failed to create customer');
  }

  return mapCustomerResponse(data);
}

export async function updateCustomer(customerId: string, payload: CustomerUpdatePayload): Promise<Customer> {
  const updateData = mapCustomerRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('customers')
    .update(updateData)
    .eq('id', parseInt(customerId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating customer:', error);
    throw new Error('Failed to update customer');
  }

  return mapCustomerResponse(data);
}

export async function deleteCustomer(customerId: string): Promise<void> {
  const { error } = await supabase
    .from('customers')
    .update({ deleted_at: new Date().toISOString() })
    .eq('id', parseInt(customerId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting customer:', error);
    throw new Error('Failed to delete customer');
  }
}
