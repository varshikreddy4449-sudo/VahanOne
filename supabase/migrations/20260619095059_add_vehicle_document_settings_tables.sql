-- Add missing fields to vehicles table
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS year INTEGER;
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS chassis_number VARCHAR(128);
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS engine_number VARCHAR(128);
ALTER TABLE vehicles ADD COLUMN IF NOT EXISTS rc_expiry_date TIMESTAMPTZ;

-- Documents table for storing vehicle documents
CREATE TABLE documents (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_id BIGINT REFERENCES vehicles(id) ON DELETE CASCADE,
    document_type VARCHAR(64) NOT NULL,
    document_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_size BIGINT,
    mime_type VARCHAR(128),
    expiry_date TIMESTAMPTZ,
    uploaded_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_documents_organization_id ON documents (organization_id);
CREATE INDEX ix_documents_vehicle_id ON documents (vehicle_id);
CREATE INDEX ix_documents_type ON documents (document_type);

-- Company settings table
CREATE TABLE company_settings (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL UNIQUE,
    company_name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(12),
    phone VARCHAR(32),
    email VARCHAR(255),
    gst_number VARCHAR(32),
    pan_number VARCHAR(20),
    website VARCHAR(255),
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    bank_ifsc_code VARCHAR(20),
    invoice_prefix VARCHAR(20) DEFAULT 'INV',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_company_settings_organization_id ON company_settings (organization_id);

-- User profiles table (extends Supabase auth.users)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE,
    organization_id UUID NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(32),
    avatar_url TEXT,
    role VARCHAR(50) DEFAULT 'vehicle_owner',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_user_profiles_user_id ON user_profiles (user_id);
CREATE INDEX ix_user_profiles_organization_id ON user_profiles (organization_id);

-- Enable RLS
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- RLS policies for documents
CREATE POLICY "select_own_documents" ON documents FOR SELECT
    TO authenticated USING (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "insert_own_documents" ON documents FOR INSERT
    TO authenticated WITH CHECK (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "update_own_documents" ON documents FOR UPDATE
    TO authenticated USING (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "delete_own_documents" ON documents FOR DELETE
    TO authenticated USING (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));

-- RLS policies for company_settings
CREATE POLICY "select_own_company_settings" ON company_settings FOR SELECT
    TO authenticated USING (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "insert_own_company_settings" ON company_settings FOR INSERT
    TO authenticated WITH CHECK (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "update_own_company_settings" ON company_settings FOR UPDATE
    TO authenticated USING (organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));

-- RLS policies for user_profiles
CREATE POLICY "select_own_profile" ON user_profiles FOR SELECT
    TO authenticated USING (user_id = auth.uid() OR organization_id IN (
        SELECT organization_id FROM user_profiles WHERE user_id = auth.uid()
    ));
CREATE POLICY "update_own_profile" ON user_profiles FOR UPDATE
    TO authenticated USING (user_id = auth.uid());
CREATE POLICY "insert_own_profile" ON user_profiles FOR INSERT
    TO authenticated WITH CHECK (user_id = auth.uid());

-- Create storage bucket for documents
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', false)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for document uploads
CREATE POLICY "select_own_documents_storage" ON storage.objects FOR SELECT
    TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "insert_own_documents_storage" ON storage.objects FOR INSERT
    TO authenticated WITH CHECK (bucket_id = 'documents');
CREATE POLICY "update_own_documents_storage" ON storage.objects FOR UPDATE
    TO authenticated USING (bucket_id = 'documents');
CREATE POLICY "delete_own_documents_storage" ON storage.objects FOR DELETE
    TO authenticated USING (bucket_id = 'documents');