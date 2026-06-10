import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapExpenseRequest, mapExpenseResponse } from '../lib/transformers';
import type { Expense, ExpenseCategory } from '../types';

export type ExpenseCreatePayload = Omit<Expense, 'id'>;
export type ExpenseUpdatePayload = Partial<Omit<Expense, 'id'>>;

export async function fetchExpenses(): Promise<Expense[]> {
  const { data, error } = await supabase
    .from('expenses')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('expense_date', { ascending: false });

  if (error) {
    console.error('Error fetching expenses:', error);
    throw new Error('Failed to fetch expenses');
  }

  return (data || []).map(mapExpenseResponse);
}

export async function fetchExpensesByTrip(tripId: string): Promise<Expense[]> {
  const { data, error } = await supabase
    .from('expenses')
    .select('*')
    .eq('trip_id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('expense_date', { ascending: false });

  if (error) {
    console.error('Error fetching expenses by trip:', error);
    throw new Error('Failed to fetch expenses');
  }

  return (data || []).map(mapExpenseResponse);
}

export async function fetchExpensesByVehicle(vehicleId: string): Promise<Expense[]> {
  const { data, error } = await supabase
    .from('expenses')
    .select('*')
    .eq('vehicle_id', parseInt(vehicleId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .order('expense_date', { ascending: false });

  if (error) {
    console.error('Error fetching expenses by vehicle:', error);
    throw new Error('Failed to fetch expenses');
  }

  return (data || []).map(mapExpenseResponse);
}

export async function createExpense(payload: ExpenseCreatePayload & { category?: ExpenseCategory }): Promise<Expense> {
  const insertData = {
    ...mapExpenseRequest(payload as Record<string, unknown>),
    organization_id: DEFAULT_ORG_ID,
    category: payload.category || 'other',
    vehicle_id: parseInt(payload.vehicleId, 10),
  };

  // Calculate total if not provided
  if (!insertData.total_amount) {
    const total =
      (Number(payload.fuelAmount) || 0) +
      (Number(payload.tollAmount) || 0) +
      (Number(payload.parkingAmount) || 0) +
      (Number(payload.driverBataAmount) || 0) +
      (Number(payload.permitAmount) || 0) +
      (Number(payload.stateTaxAmount) || 0) +
      (Number(payload.foodAmount) || 0) +
      (Number(payload.accommodationAmount) || 0) +
      (Number(payload.miscAmount) || 0);
    insertData.total_amount = total;
  }

  const { data, error } = await supabase
    .from('expenses')
    .insert(insertData)
    .select()
    .single();

  if (error) {
    console.error('Error creating expense:', error);
    throw new Error('Failed to create expense');
  }

  return mapExpenseResponse(data);
}

export async function updateExpense(expenseId: string, payload: ExpenseUpdatePayload): Promise<Expense> {
  const updateData = mapExpenseRequest(payload as Record<string, unknown>);

  const { data, error } = await supabase
    .from('expenses')
    .update(updateData)
    .eq('id', parseInt(expenseId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .select()
    .single();

  if (error) {
    console.error('Error updating expense:', error);
    throw new Error('Failed to update expense');
  }

  return mapExpenseResponse(data);
}

export async function deleteExpense(expenseId: string): Promise<void> {
  const { error } = await supabase
    .from('expenses')
    .delete()
    .eq('id', parseInt(expenseId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (error) {
    console.error('Error deleting expense:', error);
    throw new Error('Failed to delete expense');
  }
}
