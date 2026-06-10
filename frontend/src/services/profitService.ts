import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import { mapProfitSummaryResponse, mapTripProfitResponse, mapVehicleDailyProfitResponse, mapVehicleMonthlyProfitResponse } from '../lib/transformers';
import type { ProfitSummary, TripProfit, VehicleDailyProfit, VehicleMonthlyProfit } from '../types';

export async function fetchProfitSummary(params?: { startDate?: string; endDate?: string; vehicleId?: string }): Promise<ProfitSummary> {
  let query = supabase
    .from('trip_profit_summary')
    .select('trip_revenue, total_expense, trip_profit')
    .eq('organization_id', DEFAULT_ORG_ID);

  if (params?.startDate) {
    query = query.gte('profit_date', params.startDate);
  }
  if (params?.endDate) {
    query = query.lte('profit_date', params.endDate);
  }
  if (params?.vehicleId) {
    query = query.eq('vehicle_id', parseInt(params.vehicleId, 10));
  }

  const { data, error } = await query;

  if (error) {
    console.error('Error fetching profit summary:', error);
    return { totalRevenue: 0, totalExpense: 0, totalProfit: 0 };
  }

  const summary = (data || []).reduce(
    (acc, item) => ({
      totalRevenue: acc.totalRevenue + Number(item.trip_revenue || 0),
      totalExpense: acc.totalExpense + Number(item.total_expense || 0),
      totalProfit: acc.totalProfit + Number(item.trip_profit || 0),
    }),
    { totalRevenue: 0, totalExpense: 0, totalProfit: 0 }
  );

  return mapProfitSummaryResponse({
    total_revenue: summary.totalRevenue,
    total_expense: summary.totalExpense,
    total_profit: summary.totalProfit,
  }) as ProfitSummary;
}

export async function fetchTripProfit(tripId: string): Promise<TripProfit | null> {
  const { data, error } = await supabase
    .from('trip_profit_summary')
    .select('*')
    .eq('trip_id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    console.error('Error fetching trip profit:', error);
    return null;
  }

  return mapTripProfitResponse(data) as TripProfit;
}

export async function fetchVehicleDailyProfit(vehicleId: string, params?: { startDate?: string; endDate?: string }): Promise<VehicleDailyProfit[]> {
  let query = supabase
    .from('vehicle_daily_profit')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .eq('vehicle_id', parseInt(vehicleId, 10));

  if (params?.startDate) {
    query = query.gte('profit_date', params.startDate);
  }
  if (params?.endDate) {
    query = query.lte('profit_date', params.endDate);
  }

  const { data, error } = await query.order('profit_date', { ascending: false });

  if (error) {
    console.error('Error fetching vehicle daily profit:', error);
    return [];
  }

  return (data || []).map(mapVehicleDailyProfitResponse) as VehicleDailyProfit[];
}

export async function fetchVehicleMonthlyProfit(vehicleId: string, params?: { year?: number }): Promise<VehicleMonthlyProfit[]> {
  let query = supabase
    .from('vehicle_monthly_profit')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .eq('vehicle_id', parseInt(vehicleId, 10));

  if (params?.year) {
    query = query.eq('year', params.year);
  }

  const { data, error } = await query.order('year', { ascending: false }).order('month', { ascending: false });

  if (error) {
    console.error('Error fetching vehicle monthly profit:', error);
    return [];
  }

  return (data || []).map(mapVehicleMonthlyProfitResponse) as VehicleMonthlyProfit[];
}

export async function calculateTripProfit(tripId: string): Promise<void> {
  // Get trip revenue
  const { data: trip, error: tripError } = await supabase
    .from('trips')
    .select('id, vehicle_id, trip_revenue, trip_date')
    .eq('id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (tripError || !trip) {
    console.error('Error fetching trip:', tripError);
    return;
  }

  // Get total expenses for trip
  const { data: expenses, error: expensesError } = await supabase
    .from('expenses')
    .select('total_amount')
    .eq('trip_id', parseInt(tripId, 10))
    .eq('organization_id', DEFAULT_ORG_ID);

  if (expensesError) {
    console.error('Error fetching expenses:', expensesError);
    return;
  }

  const totalExpense = (expenses || []).reduce((sum, e) => sum + Number(e.total_amount || 0), 0);
  const tripRevenue = Number(trip.trip_revenue || 0);
  const tripProfit = tripRevenue - totalExpense;

  const profitDate = trip.trip_date || new Date().toISOString().split('T')[0];
  const date = new Date(profitDate);

  // Upsert trip profit summary
  await supabase
    .from('trip_profit_summary')
    .upsert({
      organization_id: DEFAULT_ORG_ID,
      trip_id: parseInt(tripId, 10),
      vehicle_id: trip.vehicle_id,
      trip_revenue: tripRevenue,
      total_expense: totalExpense,
      trip_profit: tripProfit,
      profit_date: profitDate,
      year: date.getFullYear(),
      month: date.getMonth() + 1,
    }, { onConflict: 'trip_id' });
}
