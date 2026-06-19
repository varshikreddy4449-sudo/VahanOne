import { useState, useEffect } from 'react';
import { ChartBar as FileBarChart, Download, ListFilter as Filter, TrendingUp, TrendingDown, DollarSign, Truck, Calendar, ChartPie as PieChart } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import type { Vehicle } from '../types';

type ReportType = 'vehicle' | 'expense' | 'renewal';

interface ReportData {
  vehicles: { vehicleId: string; licensePlate: string; totalRevenue: number; totalExpense: number; totalProfit: number; tripCount: number }[];
  expenses: { category: string; total: number; count: number }[];
  renewals: { vehicleId: string; licensePlate: string; type: string; expiryDate: string; status: string; daysRemaining: number }[];
}

export function Reports() {
  const [reportType, setReportType] = useState<ReportType>('vehicle');
  const [loading, setLoading] = useState(false);
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [reportData, setReportData] = useState<ReportData>({ vehicles: [], expenses: [], renewals: [] });
  const [dateRange, setDateRange] = useState({ start: '', end: '' });
  const [selectedVehicle, setSelectedVehicle] = useState<string>('all');

  useEffect(() => {
    async function loadVehicles() {
      const { data } = await supabase
        .from('vehicles')
        .select('id, vehicle_number')
        .eq('organization_id', DEFAULT_ORG_ID)
        .is('deleted_at', null);
      if (data) {
        setVehicles(data.map(v => ({ id: String(v.id), licensePlate: v.vehicle_number } as Vehicle)));
      }
    }
    loadVehicles();
  }, []);

  useEffect(() => {
    async function loadReportData() {
      setLoading(true);
      try {
        if (reportType === 'vehicle') {
          await loadVehicleReport();
        } else if (reportType === 'expense') {
          await loadExpenseReport();
        } else {
          await loadRenewalReport();
        }
      } catch (err) {
        console.error('Error loading report:', err);
      } finally {
        setLoading(false);
      }
    }

    loadReportData();
  }, [reportType, dateRange, selectedVehicle]);

  async function loadVehicleReport() {
    const { data: tripProfits } = await supabase
      .from('trip_profit_summary')
      .select('vehicle_id, trip_revenue, total_expense, trip_profit')
      .eq('organization_id', DEFAULT_ORG_ID);

    if (!tripProfits) {
      setReportData(prev => ({ ...prev, vehicles: [] }));
      return;
    }

    const vehicleStats = new Map<string, { revenue: number; expense: number; profit: number; trips: number }>();
    tripProfits.forEach(tp => {
      const vid = String(tp.vehicle_id);
      const existing = vehicleStats.get(vid) || { revenue: 0, expense: 0, profit: 0, trips: 0 };
      vehicleStats.set(vid, {
        revenue: existing.revenue + Number(tp.trip_revenue),
        expense: existing.expense + Number(tp.total_expense),
        profit: existing.profit + Number(tp.trip_profit),
        trips: existing.trips + 1,
      });
    });

    const vehiclesData = Array.from(vehicleStats.entries()).map(([vehicleId, stats]) => {
      const vehicle = vehicles.find(v => v.id === vehicleId);
      return {
        vehicleId,
        licensePlate: vehicle?.licensePlate || 'Unknown',
        totalRevenue: stats.revenue,
        totalExpense: stats.expense,
        totalProfit: stats.profit,
        tripCount: stats.trips,
      };
    });

    setReportData(prev => ({ ...prev, vehicles: vehiclesData }));
  }

  async function loadExpenseReport() {
    let query = supabase
      .from('expenses')
      .select('category, amount, total_amount')
      .eq('organization_id', DEFAULT_ORG_ID);

    if (dateRange.start) {
      query = query.gte('expense_date', dateRange.start);
    }
    if (dateRange.end) {
      query = query.lte('expense_date', dateRange.end);
    }

    const { data: expenses } = await query;

    if (!expenses) {
      setReportData(prev => ({ ...prev, expenses: [] }));
      return;
    }

    const categoryStats = new Map<string, { total: number; count: number }>();
    expenses.forEach(e => {
      const cat = e.category || 'other';
      const existing = categoryStats.get(cat) || { total: 0, count: 0 };
      categoryStats.set(cat, {
        total: existing.total + Number(e.total_amount || e.amount || 0),
        count: existing.count + 1,
      });
    });

    const expensesData = Array.from(categoryStats.entries()).map(([category, stats]) => ({
      category: category.charAt(0).toUpperCase() + category.slice(1),
      total: stats.total,
      count: stats.count,
    }));

    setReportData(prev => ({ ...prev, expenses: expensesData }));
  }

  async function loadRenewalReport() {
    const { data: vehicleData } = await supabase
      .from('vehicles')
      .select('id, vehicle_number, insurance_expiry_date, permit_expiry_date, fc_expiry_date, pollution_expiry_date, road_tax_expiry_date, rc_expiry_date')
      .eq('organization_id', DEFAULT_ORG_ID)
      .is('deleted_at', null);

    if (!vehicleData) {
      setReportData(prev => ({ ...prev, renewals: [] }));
      return;
    }

    const now = new Date();
    const renewals: ReportData['renewals'] = [];

    vehicleData.forEach(v => {
      const expiryFields = [
        { key: 'rc_expiry_date', label: 'RC' },
        { key: 'insurance_expiry_date', label: 'Insurance' },
        { key: 'permit_expiry_date', label: 'Permit' },
        { key: 'fc_expiry_date', label: 'Fitness Certificate' },
        { key: 'pollution_expiry_date', label: 'Pollution' },
        { key: 'road_tax_expiry_date', label: 'Road Tax' },
      ];

      expiryFields.forEach(({ key, label }) => {
        const dateValue = v[key as keyof typeof v];
        if (dateValue) {
          const expiryDate = new Date(dateValue as string);
          const daysRemaining = Math.ceil((expiryDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));
          const status = daysRemaining < 0 ? 'expired' : daysRemaining <= 30 ? 'warning' : 'valid';

          renewals.push({
            vehicleId: String(v.id),
            licensePlate: v.vehicle_number,
            type: label,
            expiryDate: dateValue as string,
            status,
            daysRemaining,
          });
        }
      });
    });

    renewals.sort((a, b) => a.daysRemaining - b.daysRemaining);
    setReportData(prev => ({ ...prev, renewals }));
  }

  function formatCurrency(amount: number) {
    return new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(amount);
  }

  function formatDate(dateString: string) {
    return new Date(dateString).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' });
  }

  const reportTypes = [
    { id: 'vehicle' as const, label: 'Vehicle-wise Report', icon: Truck },
    { id: 'expense' as const, label: 'Expense Report', icon: DollarSign },
    { id: 'renewal' as const, label: 'Renewal Report', icon: Calendar },
  ];

  return (
    <div className="space-y-6">
      <div className="rounded-3xl bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-semibold text-slate-900">Reports</h1>
        <p className="mt-1 text-sm text-slate-600">Generate vehicle, expense, and renewal reports</p>
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        {reportTypes.map((type) => {
          const Icon = type.icon;
          const isActive = reportType === type.id;
          return (
            <button
              key={type.id}
              onClick={() => setReportType(type.id)}
              className={`flex items-center gap-3 rounded-2xl border p-4 text-left transition ${
                isActive
                  ? 'border-primary-500 bg-primary-50 text-primary-700'
                  : 'border-slate-200 bg-white hover:border-slate-300'
              }`}
            >
              <div className={`flex h-10 w-10 items-center justify-center rounded-xl ${isActive ? 'bg-primary-100' : 'bg-slate-100'}`}>
                <Icon className={`h-5 w-5 ${isActive ? 'text-primary-600' : 'text-slate-500'}`} />
              </div>
              <span className="font-medium">{type.label}</span>
            </button>
          );
        })}
      </div>

      {reportType === 'expense' && (
        <Card className="p-4">
          <div className="flex flex-wrap items-center gap-4">
            <div className="flex items-center gap-2">
              <Filter className="h-4 w-4 text-slate-400" />
              <span className="text-sm font-medium text-slate-700">Filter by date:</span>
            </div>
            <Input
              type="date"
              value={dateRange.start}
              onChange={(e) => setDateRange(prev => ({ ...prev, start: e.target.value }))}
              className="max-w-xs"
            />
            <span className="text-slate-400">to</span>
            <Input
              type="date"
              value={dateRange.end}
              onChange={(e) => setDateRange(prev => ({ ...prev, end: e.target.value }))}
              className="max-w-xs"
            />
          </div>
        </Card>
      )}

      {loading ? (
        <div className="rounded-2xl border border-slate-200 bg-white p-12 text-center">
          <div className="text-slate-500">Loading report...</div>
        </div>
      ) : (
        <>
          {reportType === 'vehicle' && (
            <Card className="overflow-hidden">
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200">
                  <thead className="bg-slate-50">
                    <tr>
                      <th className="px-6 py-4 text-left text-sm font-medium text-slate-600">Vehicle</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-slate-600">Trips</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-slate-600">Revenue</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-slate-600">Expense</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-slate-600">Profit</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 bg-white">
                    {reportData.vehicles.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                          No vehicle data available
                        </td>
                      </tr>
                    ) : (
                      reportData.vehicles.map((v) => (
                        <tr key={v.vehicleId} className="hover:bg-slate-50">
                          <td className="px-6 py-4 font-medium text-slate-900">{v.licensePlate}</td>
                          <td className="px-6 py-4 text-right text-slate-600">{v.tripCount}</td>
                          <td className="px-6 py-4 text-right text-slate-600">{formatCurrency(v.totalRevenue)}</td>
                          <td className="px-6 py-4 text-right text-slate-600">{formatCurrency(v.totalExpense)}</td>
                          <td className="px-6 py-4 text-right">
                            <span className={`inline-flex items-center gap-1 font-medium ${v.totalProfit >= 0 ? 'text-emerald-600' : 'text-red-600'}`}>
                              {v.totalProfit >= 0 ? <TrendingUp className="h-4 w-4" /> : <TrendingDown className="h-4 w-4" />}
                              {formatCurrency(v.totalProfit)}
                            </span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </Card>
          )}

          {reportType === 'expense' && (
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
              {reportData.expenses.length === 0 ? (
                <div className="col-span-full rounded-2xl border border-dashed border-slate-200 bg-slate-50 p-8 text-center text-slate-500">
                  No expense data for the selected period
                </div>
              ) : (
                reportData.expenses.map((e) => (
                  <div key={e.category} className="rounded-2xl border border-slate-200 bg-white p-4">
                    <div className="flex items-center justify-between">
                      <span className="font-medium text-slate-900">{e.category}</span>
                      <span className="rounded-full bg-slate-100 px-2 py-1 text-xs font-medium text-slate-600">
                        {e.count} entries
                      </span>
                    </div>
                    <div className="mt-2 text-2xl font-semibold text-slate-900">{formatCurrency(e.total)}</div>
                  </div>
                ))
              )}
            </div>
          )}

          {reportType === 'renewal' && (
            <Card className="overflow-hidden">
              <div className="overflow-x-auto">
                <table className="min-w-full divide-y divide-slate-200">
                  <thead className="bg-slate-50">
                    <tr>
                      <th className="px-6 py-4 text-left text-sm font-medium text-slate-600">Vehicle</th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-slate-600">Type</th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-slate-600">Expiry Date</th>
                      <th className="px-6 py-4 text-right text-sm font-medium text-slate-600">Days Remaining</th>
                      <th className="px-6 py-4 text-left text-sm font-medium text-slate-600">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 bg-white">
                    {reportData.renewals.length === 0 ? (
                      <tr>
                        <td colSpan={5} className="px-6 py-8 text-center text-slate-500">
                          No renewal data available
                        </td>
                      </tr>
                    ) : (
                      reportData.renewals.map((r, idx) => (
                        <tr key={idx} className="hover:bg-slate-50">
                          <td className="px-6 py-4 font-medium text-slate-900">{r.licensePlate}</td>
                          <td className="px-6 py-4 text-slate-600">{r.type}</td>
                          <td className="px-6 py-4 text-slate-600">{formatDate(r.expiryDate)}</td>
                          <td className="px-6 py-4 text-right text-slate-600">
                            {r.daysRemaining < 0 ? `${Math.abs(r.daysRemaining)} days ago` : `${r.daysRemaining} days`}
                          </td>
                          <td className="px-6 py-4">
                            <span className={`rounded-full px-3 py-1 text-xs font-semibold ${
                              r.status === 'expired'
                                ? 'bg-red-100 text-red-700'
                                : r.status === 'warning'
                                ? 'bg-amber-100 text-amber-700'
                                : 'bg-emerald-100 text-emerald-700'
                            }`}>
                              {r.status === 'expired' ? 'Expired' : r.status === 'warning' ? 'Expiring Soon' : 'Valid'}
                            </span>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </Card>
          )}
        </>
      )}
    </div>
  );
}
