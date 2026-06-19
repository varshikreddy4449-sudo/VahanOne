import { supabase, DEFAULT_ORG_ID } from '../lib/supabase';
import type { CompanySettings } from '../types';

interface CompanySettingsRow {
  id: number;
  organization_id: string;
  company_name: string;
  logo_url: string | null;
  address: string | null;
  city: string | null;
  state: string | null;
  pincode: string | null;
  phone: string | null;
  email: string | null;
  gst_number: string | null;
  pan_number: string | null;
  website: string | null;
  bank_name: string | null;
  bank_account_number: string | null;
  bank_ifsc_code: string | null;
  invoice_prefix: string;
  created_at: string;
  updated_at: string;
}

function mapCompanySettingsResponse(row: CompanySettingsRow): CompanySettings {
  return {
    id: String(row.id),
    organizationId: row.organization_id,
    companyName: row.company_name,
    logoUrl: row.logo_url || undefined,
    address: row.address || undefined,
    city: row.city || undefined,
    state: row.state || undefined,
    pincode: row.pincode || undefined,
    phone: row.phone || undefined,
    email: row.email || undefined,
    gstNumber: row.gst_number || undefined,
    panNumber: row.pan_number || undefined,
    website: row.website || undefined,
    bankName: row.bank_name || undefined,
    bankAccountNumber: row.bank_account_number || undefined,
    bankIfscCode: row.bank_ifsc_code || undefined,
    invoicePrefix: row.invoice_prefix || 'INV',
  };
}

export async function fetchCompanySettings(): Promise<CompanySettings | null> {
  const { data, error } = await supabase
    .from('company_settings')
    .select('*')
    .eq('organization_id', DEFAULT_ORG_ID)
    .single();

  if (error) {
    if (error.code === 'PGRST116') {
      return null;
    }
    console.error('Error fetching company settings:', error);
    throw new Error('Failed to fetch company settings');
  }

  return mapCompanySettingsResponse(data);
}

export async function upsertCompanySettings(payload: Partial<CompanySettings>): Promise<CompanySettings> {
  const insertData = {
    organization_id: DEFAULT_ORG_ID,
    company_name: payload.companyName || 'My Company',
    logo_url: payload.logoUrl || null,
    address: payload.address || null,
    city: payload.city || null,
    state: payload.state || null,
    pincode: payload.pincode || null,
    phone: payload.phone || null,
    email: payload.email || null,
    gst_number: payload.gstNumber || null,
    pan_number: payload.panNumber || null,
    website: payload.website || null,
    bank_name: payload.bankName || null,
    bank_account_number: payload.bankAccountNumber || null,
    bank_ifsc_code: payload.bankIfscCode || null,
    invoice_prefix: payload.invoicePrefix || 'INV',
  };

  const { data, error } = await supabase
    .from('company_settings')
    .upsert(insertData, { onConflict: 'organization_id' })
    .select()
    .single();

  if (error) {
    console.error('Error upserting company settings:', error);
    throw new Error('Failed to save company settings');
  }

  return mapCompanySettingsResponse(data);
}

export async function uploadLogo(file: File): Promise<string> {
  const fileExt = file.name.split('.').pop();
  const fileName = `${DEFAULT_ORG_ID}/logo.${fileExt}`;

  const { error: uploadError } = await supabase.storage
    .from('documents')
    .upload(fileName, file, { upsert: true });

  if (uploadError) {
    console.error('Error uploading logo:', uploadError);
    throw new Error('Failed to upload logo');
  }

  const { data: { publicUrl } } = supabase.storage
    .from('documents')
    .getPublicUrl(fileName);

  return publicUrl;
}
