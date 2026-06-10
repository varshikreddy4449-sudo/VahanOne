import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapInvoiceRequest, mapInvoiceResponse } from '../lib/transformers';
import type { Invoice, InvoiceStatus } from '../types';

export type InvoiceCreatePayload = Omit<Invoice, 'id' | 'status' | 'total'>;
export type InvoiceUpdatePayload = Partial<Omit<Invoice, 'id' | 'status' | 'total'>>;

export async function fetchInvoices(): Promise<Invoice[]> {
  const { data, error } = await supabase
    .from('invoices')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('invoice_date', { ascending: false });

  if (error) {
    console.error('Error fetching invoices:', error);
    throw new Error('Failed to fetch invoices');
  }

  return (data || []).map(mapInvoiceResponse);
}

export async function fetchInvoice(invoiceId: string): Promise<Invoice> {
  const { data, error } = await supabase
    .from('invoices')
    .select('*')
    .eq('id', parseInt(invoiceId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching invoice:', error);
    throw new Error('Failed to fetch invoice');
  }

  return mapInvoiceResponse(data);
}

function generateInvoiceNumber(): string {
  const prefix = 'INV';
  const timestamp = Date.now().toString(36).toUpperCase();
  return `${prefix}-${timestamp}`;
}

export async function createInvoice(payload: InvoiceCreatePayload): Promise<Invoice> {
  const invoiceNumber = generateInvoiceNumber();
  const subtotal = payload.subtotal || 0;
  const taxAmount = payload.taxAmount || 0;
  const totalAmount = subtotal + taxAmount;

  const insertData = {
    ...mapInvoiceRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
    invoice_number: invoiceNumber,
    customer_id: payload.customerId ? parseInt(payload.customerId, 10) : null,
    trip_id: payload.tripId ? parseInt(payload.tripId, 10) : null,
    subtotal,
    tax_amount: taxAmount,
    total_amount: totalAmount,
    status: 'draft',
  };

  const { data, error } = await supabase
    .from('invoices')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating invoice:', error);
    throw new Error('Failed to create invoice');
  }

  return mapInvoiceResponse(data);
}

export async function updateInvoice(invoiceId: string, payload: InvoiceUpdatePayload): Promise<Invoice> {
  const updateData = mapInvoiceRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('invoices')
    .update(updateData)
    .eq('id', parseInt(invoiceId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating invoice:', error);
    throw new Error('Failed to update invoice');
  }

  return mapInvoiceResponse(data);
}

export async function markInvoicePaid(invoiceId: string): Promise<Invoice> {
  const { data, error } = await supabase
    .from('invoices')
    .update({ status: 'paid' })
    .eq('id', parseInt(invoiceId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error marking invoice as paid:', error);
    throw new Error('Failed to mark invoice as paid');
  }

  return mapInvoiceResponse(data);
}

export async function deleteInvoice(invoiceId: string): Promise<void> {
  const { error } = await supabase
    .from('invoices')
    .delete()
    .eq('id', parseInt(invoiceId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting invoice:', error);
    throw new Error('Failed to delete invoice');
  }
}
