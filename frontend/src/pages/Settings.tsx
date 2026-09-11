import { useEffect, useState } from 'react';
import { Building2, MapPin, Phone, Mail, Globe, CreditCard, FileText, Upload, Save, CircleAlert as AlertCircle, CircleCheck as CheckCircle } from 'lucide-react';
import { Button } from '../components/ui/Button';
import { Card } from '../components/ui/Card';
import { Input } from '../components/ui/Input';
import { fetchCompanySettings, upsertCompanySettings, uploadLogo } from '../services/settingsService';
import { useAuth, updateProfile } from '../hooks/useAuth';
import type { CompanySettings, User } from '../types';

type SettingsTab = 'company' | 'profile';

export function Settings() {
  const { user } = useAuth();
  const [activeTab, setActiveTab] = useState<SettingsTab>('company');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState('');

  const [companySettings, setCompanySettings] = useState<Partial<CompanySettings>>({
    companyName: '',
    address: '',
    city: '',
    state: '',
    pincode: '',
    phone: '',
    email: '',
    gstNumber: '',
    panNumber: '',
    website: '',
    bankName: '',
    bankAccountNumber: '',
    bankIfscCode: '',
    invoicePrefix: 'INV',
  });

  const [profile, setProfile] = useState({
    fullName: '',
    phone: '',
    email: '',
  });

  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [logoPreview, setLogoPreview] = useState<string | null>(null);

  useEffect(() => {
    async function loadSettings() {
      try {
        const settings = await fetchCompanySettings();
        if (settings) {
          setCompanySettings({
            companyName: settings.companyName,
            logoUrl: settings.logoUrl,
            address: settings.address,
            city: settings.city,
            state: settings.state,
            pincode: settings.pincode,
            phone: settings.phone,
            email: settings.email,
            gstNumber: settings.gstNumber,
            panNumber: settings.panNumber,
            website: settings.website,
            bankName: settings.bankName,
            bankAccountNumber: settings.bankAccountNumber,
            bankIfscCode: settings.bankIfscCode,
            invoicePrefix: settings.invoicePrefix,
          });
          if (settings.logoUrl) {
            setLogoPreview(settings.logoUrl);
          }
        }
      } catch (err) {
        console.error('Failed to load settings:', err);
      }
    }

    loadSettings();

    if (user) {
      setProfile({
        fullName: user.fullName || '',
        phone: user.phone || '',
        email: user.email || '',
      });
    }
  }, [user]);

  async function handleCompanySave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError('');
    setSaved(false);

    try {
      let logoUrl = companySettings.logoUrl;
      if (logoFile) {
        logoUrl = await uploadLogo(logoFile);
        setCompanySettings((prev) => ({ ...prev, logoUrl }));
        setLogoPreview(logoUrl);
      }

      await upsertCompanySettings({
        ...companySettings,
        logoUrl,
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    } catch (err) {
      setError('Failed to save settings');
    } finally {
      setSaving(false);
    }
  }

  async function handleProfileSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError('');
    setSaved(false);

    try {
      await updateProfile({
        fullName: profile.fullName,
        phone: profile.phone,
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 3000);
    } catch (err) {
      setError('Failed to update profile');
    } finally {
      setSaving(false);
    }
  }

  function handleLogoSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) {
      setLogoFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setLogoPreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  const tabs: { id: SettingsTab; label: string }[] = [
    { id: 'company', label: 'Company Details' },
    { id: 'profile', label: 'Profile' },
  ];

  return (
    <div className="space-y-6">
      <div className="rounded-3xl bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-semibold text-slate-900">Settings</h1>
        <p className="mt-1 text-sm text-slate-600">Manage your company and profile settings</p>
      </div>

      <div className="border-b border-slate-200">
        <nav className="flex gap-4">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`border-b-2 px-4 py-3 text-sm font-medium transition-colors ${
                activeTab === tab.id
                  ? 'border-primary-600 text-primary-600'
                  : 'border-transparent text-slate-500 hover:border-slate-300 hover:text-slate-700'
              }`}
            >
              {tab.label}
            </button>
          ))}
        </nav>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-xl bg-red-50 p-4 text-red-700">
          <AlertCircle className="h-4 w-4" />
          {error}
        </div>
      )}

      {saved && (
        <div className="flex items-center gap-2 rounded-xl bg-emerald-50 p-4 text-emerald-700">
          <CheckCircle className="h-4 w-4" />
          Settings saved successfully
        </div>
      )}

      {activeTab === 'company' && (
        <form onSubmit={handleCompanySave} className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 flex items-center gap-2 text-lg font-semibold text-slate-900">
              <Building2 className="h-5 w-5 text-primary-600" />
              Company Information
            </h2>
            <div className="grid gap-6 md:grid-cols-2">
              <div className="space-y-4 md:col-span-2">
                <label className="block text-sm font-medium text-slate-700">Company Logo</label>
                <div className="flex items-center gap-4">
                  {logoPreview ? (
                    <img src={logoPreview} alt="Logo" className="h-16 w-16 rounded-xl object-cover border border-slate-200" />
                  ) : (
                    <div className="flex h-16 w-16 items-center justify-center rounded-xl bg-slate-100">
                      <Building2 className="h-8 w-8 text-slate-400" />
                    </div>
                  )}
                  <label className="cursor-pointer">
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={handleLogoSelect}
                    />
                    <Button type="button" variant="outline" className="cursor-pointer">
                      <Upload className="mr-2 h-4 w-4" />
                      Upload Logo
                    </Button>
                  </label>
                </div>
              </div>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Company Name *</span>
                <Input
                  value={companySettings.companyName || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, companyName: e.target.value }))}
                  required
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Phone</span>
                <Input
                  value={companySettings.phone || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, phone: e.target.value }))}
                  type="tel"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Email</span>
                <Input
                  value={companySettings.email || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, email: e.target.value }))}
                  type="email"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Website</span>
                <Input
                  value={companySettings.website || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, website: e.target.value }))}
                  type="url"
                  placeholder="https://example.com"
                />
              </label>
              <label className="space-y-2 md:col-span-2">
                <span className="text-sm font-medium text-slate-700">Address</span>
                <Input
                  value={companySettings.address || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, address: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">City</span>
                <Input
                  value={companySettings.city || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, city: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">State</span>
                <Input
                  value={companySettings.state || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, state: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Pincode</span>
                <Input
                  value={companySettings.pincode || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, pincode: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">GST Number</span>
                <Input
                  value={companySettings.gstNumber || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, gstNumber: e.target.value.toUpperCase() }))}
                  placeholder="22AAAAA0000A1Z5"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">PAN Number</span>
                <Input
                  value={companySettings.panNumber || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, panNumber: e.target.value.toUpperCase() }))}
                  placeholder="AAAAA0000A"
                />
              </label>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 flex items-center gap-2 text-lg font-semibold text-slate-900">
              <CreditCard className="h-5 w-5 text-primary-600" />
              Bank Details
            </h2>
            <div className="grid gap-6 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Bank Name</span>
                <Input
                  value={companySettings.bankName || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, bankName: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Account Number</span>
                <Input
                  value={companySettings.bankAccountNumber || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, bankAccountNumber: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">IFSC Code</span>
                <Input
                  value={companySettings.bankIfscCode || ''}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, bankIfscCode: e.target.value.toUpperCase() }))}
                  placeholder="ABCD0123456"
                />
              </label>
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 flex items-center gap-2 text-lg font-semibold text-slate-900">
              <FileText className="h-5 w-5 text-primary-600" />
              Invoice Settings
            </h2>
            <div className="grid gap-6 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Invoice Prefix</span>
                <Input
                  value={companySettings.invoicePrefix || 'INV'}
                  onChange={(e) => setCompanySettings((prev) => ({ ...prev, invoicePrefix: e.target.value.toUpperCase() }))}
                  placeholder="INV"
                  className="max-w-xs"
                />
              </label>
            </div>
          </Card>

          <div className="flex justify-end">
            <Button type="submit" className="bg-primary-600 hover:bg-primary-700" disabled={saving}>
              <Save className="mr-2 h-4 w-4" />
              {saving ? 'Saving...' : 'Save Settings'}
            </Button>
          </div>
        </form>
      )}

      {activeTab === 'profile' && (
        <form onSubmit={handleProfileSave} className="space-y-6">
          <Card className="p-6">
            <h2 className="mb-4 text-lg font-semibold text-slate-900">Profile Information</h2>
            <div className="grid gap-6 md:grid-cols-2">
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Full Name</span>
                <Input
                  value={profile.fullName}
                  onChange={(e) => setProfile((prev) => ({ ...prev, fullName: e.target.value }))}
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Email</span>
                <Input
                  value={profile.email}
                  disabled
                  className="bg-slate-50 text-slate-500"
                />
              </label>
              <label className="space-y-2">
                <span className="text-sm font-medium text-slate-700">Phone</span>
                <Input
                  value={profile.phone}
                  onChange={(e) => setProfile((prev) => ({ ...prev, phone: e.target.value }))}
                  type="tel"
                />
              </label>
            </div>
          </Card>

          <div className="flex justify-end">
            <Button type="submit" className="bg-primary-600 hover:bg-primary-700" disabled={saving}>
              <Save className="mr-2 h-4 w-4" />
              {saving ? 'Saving...' : 'Save Profile'}
            </Button>
          </div>
        </form>
      )}
    </div>
  );
}
