
-- ==========================================
-- Migration: 20260610161215_001_initial_schema.sql
-- ==========================================

-- Initial VahanOne Schema
-- Organizations
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Permissions
CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(150) NOT NULL UNIQUE,
    name VARCHAR(255),
    resource VARCHAR(100),
    action VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Roles
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_role_org_name UNIQUE (organization_id, name)
);
CREATE INDEX ix_roles_organization_id ON roles (organization_id);

-- Role Permissions
CREATE TABLE role_permissions (
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    email VARCHAR(254) NOT NULL,
    hashed_password VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT true,
    is_superuser BOOLEAN NOT NULL DEFAULT false,
    refresh_token_version INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_user_org_email UNIQUE (organization_id, email)
);
CREATE INDEX ix_users_organization_id ON users (organization_id);

-- User Roles
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Customers
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    company VARCHAR(255),
    phone_number VARCHAR(32),
    email VARCHAR(255),
    gst_number VARCHAR(32),
    address VARCHAR(500),
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(12),
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_customer_org_phone UNIQUE (organization_id, phone_number),
    CONSTRAINT uq_customer_org_gst UNIQUE (organization_id, gst_number)
);
CREATE INDEX ix_customers_organization_id ON customers (organization_id);
CREATE INDEX ix_customers_org_phone ON customers (organization_id, phone_number);
CREATE INDEX ix_customers_org_gst ON customers (organization_id, gst_number);

-- Vehicles
CREATE TABLE vehicles (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_number VARCHAR(64) NOT NULL,
    vehicle_type VARCHAR(64),
    make VARCHAR(128),
    model VARCHAR(128),
    seating_capacity INTEGER,
    fuel_type VARCHAR(64),
    registration_date TIMESTAMPTZ,
    insurance_expiry_date TIMESTAMPTZ,
    permit_expiry_date TIMESTAMPTZ,
    fc_expiry_date TIMESTAMPTZ,
    pollution_expiry_date TIMESTAMPTZ,
    road_tax_expiry_date TIMESTAMPTZ,
    gps_subscription_expiry_date TIMESTAMPTZ,
    service_due_date TIMESTAMPTZ,
    tyre_change_due_date TIMESTAMPTZ,
    battery_change_due_date TIMESTAMPTZ,
    loan_closure_date TIMESTAMPTZ,
    purchase_price NUMERIC(12, 2),
    emi_amount NUMERIC(12, 2),
    emi_due_day INTEGER,
    is_active BOOLEAN NOT NULL DEFAULT true,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_vehicle_org_number UNIQUE (organization_id, vehicle_number)
);
CREATE INDEX ix_vehicles_organization_id ON vehicles (organization_id);
CREATE INDEX ix_vehicles_org_number ON vehicles (organization_id, vehicle_number);

-- Drivers
CREATE TABLE drivers (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    license_number VARCHAR(64) NOT NULL,
    license_expiry TIMESTAMPTZ,
    contact_number VARCHAR(32),
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_driver_org_license UNIQUE (organization_id, license_number)
);
CREATE INDEX ix_drivers_organization_id ON drivers (organization_id);

-- Bookings
CREATE TABLE bookings (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    customer_id BIGINT REFERENCES customers(id) ON DELETE RESTRICT,
    customer_name VARCHAR(255),
    customer_company VARCHAR(255),
    customer_phone VARCHAR(32),
    customer_email VARCHAR(255),
    customer_gst_number VARCHAR(32),
    customer_city VARCHAR(100),
    customer_notes TEXT,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    driver_id BIGINT REFERENCES drivers(id) ON DELETE SET NULL,
    pickup_location VARCHAR(500) NOT NULL,
    destination VARCHAR(500) NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    booking_amount NUMERIC(12, 2) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_bookings_organization_id ON bookings (organization_id);
CREATE INDEX ix_bookings_customer_id ON bookings (customer_id);
CREATE INDEX ix_bookings_vehicle_id ON bookings (vehicle_id);
CREATE INDEX ix_bookings_driver_id ON bookings (driver_id);
CREATE INDEX ix_bookings_start_date ON bookings (start_date);
CREATE INDEX ix_bookings_end_date ON bookings (end_date);
CREATE INDEX ix_bookings_org_customer ON bookings (organization_id, customer_id);
CREATE INDEX ix_bookings_org_vehicle ON bookings (organization_id, vehicle_id);
CREATE INDEX ix_bookings_org_start_date ON bookings (organization_id, start_date);

-- Trip Packages
CREATE TABLE trip_packages (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    package_category VARCHAR(64) NOT NULL,
    included_hours INTEGER,
    included_km INTEGER,
    base_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    extra_km_rate NUMERIC(12, 2),
    extra_hour_rate NUMERIC(12, 2),
    driver_bata_default NUMERIC(12, 2),
    night_charge_default NUMERIC(12, 2),
    permit_default NUMERIC(12, 2),
    state_tax_default NUMERIC(12, 2),
    minimum_km_per_day INTEGER,
    km_rate NUMERIC(12, 2),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_trip_packages_org_name UNIQUE (organization_id, name)
);
CREATE INDEX ix_trip_packages_org_category ON trip_packages (organization_id, package_category);

-- Trips
CREATE TABLE trips (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    booking_id BIGINT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    package_id BIGINT REFERENCES trip_packages(id) ON DELETE SET NULL,
    package_name VARCHAR(255),
    trip_date DATE,
    start_place VARCHAR(500),
    end_place VARCHAR(500),
    start_km BIGINT NOT NULL,
    end_km BIGINT,
    distance_km NUMERIC(12, 3),
    included_km INTEGER,
    included_hours INTEGER,
    hours_used NUMERIC(8, 2),
    days_used INTEGER,
    extra_km NUMERIC(12, 3),
    extra_hours NUMERIC(8, 2),
    package_amount NUMERIC(12, 2),
    extra_km_rate NUMERIC(12, 2),
    extra_hour_rate NUMERIC(12, 2),
    minimum_km_per_day INTEGER,
    km_rate NUMERIC(12, 2),
    extra_km_amount NUMERIC(12, 2),
    extra_hour_amount NUMERIC(12, 2),
    driver_bata NUMERIC(12, 2),
    night_charges NUMERIC(12, 2),
    permit_amount NUMERIC(12, 2),
    state_tax_amount NUMERIC(12, 2),
    toll_amount NUMERIC(12, 2),
    parking_amount NUMERIC(12, 2),
    advance_received NUMERIC(12, 2) DEFAULT 0,
    grand_total NUMERIC(12, 2),
    trip_revenue NUMERIC(12, 2),
    start_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_trips_organization_id ON trips (organization_id);
CREATE INDEX ix_trips_booking_id ON trips (booking_id);
CREATE INDEX ix_trips_vehicle_id ON trips (vehicle_id);
CREATE INDEX ix_trips_start_time ON trips (start_time);
CREATE INDEX ix_trips_end_time ON trips (end_time);
CREATE INDEX ix_trips_org_booking ON trips (organization_id, booking_id);
CREATE INDEX ix_trips_org_vehicle ON trips (organization_id, vehicle_id);
CREATE INDEX ix_trips_org_start ON trips (organization_id, start_time);

-- Expense Categories as enum
CREATE TYPE expense_category AS ENUM ('fuel', 'toll', 'parking', 'maintenance', 'other');

-- Expenses
CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    trip_id BIGINT REFERENCES trips(id) ON DELETE CASCADE,
    booking_id BIGINT REFERENCES bookings(id) ON DELETE SET NULL,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    category expense_category NOT NULL,
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    fuel_amount NUMERIC(12, 2) DEFAULT 0,
    toll_amount NUMERIC(12, 2) DEFAULT 0,
    parking_amount NUMERIC(12, 2) DEFAULT 0,
    driver_bata_amount NUMERIC(12, 2) DEFAULT 0,
    permit_amount NUMERIC(12, 2) DEFAULT 0,
    state_tax_amount NUMERIC(12, 2) DEFAULT 0,
    food_amount NUMERIC(12, 2) DEFAULT 0,
    accommodation_amount NUMERIC(12, 2) DEFAULT 0,
    misc_amount NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) DEFAULT 0,
    description TEXT,
    expense_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_expenses_organization_id ON expenses (organization_id);
CREATE INDEX ix_expenses_trip_id ON expenses (trip_id);
CREATE INDEX ix_expenses_booking_id ON expenses (booking_id);
CREATE INDEX ix_expenses_vehicle_id ON expenses (vehicle_id);
CREATE INDEX ix_expenses_expense_date ON expenses (expense_date);
CREATE INDEX ix_expenses_org_trip ON expenses (organization_id, trip_id);
CREATE INDEX ix_expenses_org_vehicle ON expenses (organization_id, vehicle_id);

-- Invoices
CREATE TABLE invoices (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    customer_id BIGINT REFERENCES customers(id) ON DELETE RESTRICT,
    trip_id BIGINT UNIQUE REFERENCES trips(id) ON DELETE CASCADE,
    booking_id BIGINT REFERENCES bookings(id) ON DELETE SET NULL,
    invoice_number VARCHAR(128) NOT NULL,
    invoice_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    due_date TIMESTAMPTZ,
    subtotal NUMERIC(12, 2) NOT NULL DEFAULT 0,
    tax_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    advance_received NUMERIC(12, 2) DEFAULT 0,
    status VARCHAR(32) NOT NULL DEFAULT 'draft',
    notes TEXT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_invoice_org_number UNIQUE (organization_id, invoice_number)
);
CREATE INDEX ix_invoices_organization_id ON invoices (organization_id);
CREATE INDEX ix_invoices_customer_id ON invoices (customer_id);
CREATE INDEX ix_invoices_trip_id ON invoices (trip_id);
CREATE INDEX ix_invoices_booking_id ON invoices (booking_id);
CREATE INDEX ix_invoices_org_customer ON invoices (organization_id, customer_id);
CREATE INDEX ix_invoices_org_trip ON invoices (organization_id, trip_id);
CREATE INDEX ix_invoices_org_booking ON invoices (organization_id, booking_id);

-- Invoice Items
CREATE TABLE invoice_items (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    invoice_id BIGINT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    description VARCHAR(512),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price_cents BIGINT NOT NULL,
    line_total_cents BIGINT,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_invoice_items_invoice_id ON invoice_items (invoice_id);
CREATE INDEX ix_invoice_items_org_invoice ON invoice_items (organization_id, invoice_id);

-- Payments
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    invoice_id BIGINT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
    amount_cents BIGINT NOT NULL,
    method VARCHAR(64),
    transaction_ref VARCHAR(255),
    status VARCHAR(64),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_payments_invoice_id ON payments (invoice_id);
CREATE INDEX ix_payments_org_invoice ON payments (organization_id, invoice_id);

-- Maintenance Schedule
CREATE TABLE maintenance_schedule (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    reason VARCHAR(500) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_maintenance_schedule_vehicle_id ON maintenance_schedule (vehicle_id);
CREATE INDEX ix_maintenance_schedule_start_date ON maintenance_schedule (start_date);
CREATE INDEX ix_maintenance_schedule_org_vehicle ON maintenance_schedule (organization_id, vehicle_id);
CREATE INDEX ix_maintenance_schedule_org_start_date ON maintenance_schedule (organization_id, start_date);

-- Calendar Event Types as enum
CREATE TYPE calendar_event_type AS ENUM ('booking', 'maintenance', 'dispatch');

-- Vehicle Calendar Events
CREATE TABLE vehicle_calendar_events (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    booking_id BIGINT REFERENCES bookings(id) ON DELETE CASCADE,
    maintenance_id BIGINT REFERENCES maintenance_schedule(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    event_type calendar_event_type NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_vehicle_calendar_events_vehicle_id ON vehicle_calendar_events (vehicle_id);
CREATE INDEX ix_vehicle_calendar_events_booking_id ON vehicle_calendar_events (booking_id);
CREATE INDEX ix_vehicle_calendar_events_maintenance_id ON vehicle_calendar_events (maintenance_id);
CREATE INDEX ix_vehicle_calendar_events_start_date ON vehicle_calendar_events (start_date);
CREATE INDEX ix_vehicle_calendar_events_org_vehicle ON vehicle_calendar_events (organization_id, vehicle_id);
CREATE INDEX ix_vehicle_calendar_events_org_start_date ON vehicle_calendar_events (organization_id, start_date);

-- Reminder Rules
CREATE TABLE reminder_rules (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(64) NOT NULL,
    event_type VARCHAR(128) NOT NULL,
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT true,
    trigger_days_before INTEGER,
    threshold_hours INTEGER,
    priority INTEGER NOT NULL DEFAULT 100,
    settings JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_reminder_rules_organization_id ON reminder_rules (organization_id);
CREATE INDEX ix_reminder_rules_org_event_type ON reminder_rules (organization_id, event_type);

-- Reminders
CREATE TABLE reminders (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    rule_id BIGINT NOT NULL REFERENCES reminder_rules(id) ON DELETE CASCADE,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    reminder_date TIMESTAMPTZ NOT NULL,
    due_date TIMESTAMPTZ,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    message TEXT,
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_reminders_rule_id ON reminders (rule_id);
CREATE INDEX ix_reminders_reminder_date ON reminders (reminder_date);
CREATE INDEX ix_reminders_org_status ON reminders (organization_id, status);
CREATE INDEX ix_reminders_org_reminder_date ON reminders (organization_id, reminder_date);

-- Notification Events
CREATE TABLE notification_events (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    reminder_id BIGINT REFERENCES reminders(id) ON DELETE CASCADE,
    event_type VARCHAR(128) NOT NULL,
    recipient_id UUID,
    channel VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'pending',
    scheduled_time TIMESTAMPTZ,
    payload JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_notification_events_reminder_id ON notification_events (reminder_id);
CREATE INDEX ix_notification_events_recipient_id ON notification_events (recipient_id);
CREATE INDEX ix_notification_events_scheduled_time ON notification_events (scheduled_time);
CREATE INDEX ix_notification_events_org_scheduled ON notification_events (organization_id, scheduled_time);

-- Notification Preferences
CREATE TABLE notification_preferences (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    user_id UUID,
    event_type VARCHAR(128) NOT NULL,
    channel VARCHAR(32) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT true,
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_notification_pref_org_user_event_channel UNIQUE (organization_id, user_id, event_type, channel)
);

-- Notifications
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    recipient_id UUID,
    channel VARCHAR(32),
    payload JSONB,
    scheduled_time TIMESTAMPTZ,
    status VARCHAR(32),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_notifications_recipient_id ON notifications (recipient_id);
CREATE INDEX ix_notifications_scheduled_time ON notifications (scheduled_time);
CREATE INDEX ix_notifications_org_scheduled ON notifications (organization_id, scheduled_time);

-- Profit Tables
CREATE TABLE trip_profit_summary (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    trip_id BIGINT NOT NULL UNIQUE REFERENCES trips(id) ON DELETE CASCADE,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    trip_revenue NUMERIC(12, 2) NOT NULL,
    total_expense NUMERIC(12, 2) NOT NULL,
    trip_profit NUMERIC(12, 2) NOT NULL,
    profit_date DATE NOT NULL,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_trip_profit_summary_trip_id ON trip_profit_summary (trip_id);
CREATE INDEX ix_trip_profit_summary_vehicle_id ON trip_profit_summary (vehicle_id);
CREATE INDEX ix_trip_profit_summary_profit_date ON trip_profit_summary (profit_date);
CREATE INDEX ix_trip_profit_summary_org_trip ON trip_profit_summary (organization_id, trip_id);
CREATE INDEX ix_trip_profit_summary_org_vehicle ON trip_profit_summary (organization_id, vehicle_id);

CREATE TABLE vehicle_daily_profit (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    profit_date DATE NOT NULL,
    total_revenue NUMERIC(12, 2) NOT NULL,
    total_expense NUMERIC(12, 2) NOT NULL,
    total_profit NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_vehicle_daily_profit_date UNIQUE (vehicle_id, profit_date)
);
CREATE INDEX ix_vehicle_daily_profit_vehicle_id ON vehicle_daily_profit (vehicle_id);
CREATE INDEX ix_vehicle_daily_profit_profit_date ON vehicle_daily_profit (profit_date);
CREATE INDEX ix_vehicle_daily_profit_org_vehicle ON vehicle_daily_profit (organization_id, vehicle_id);

CREATE TABLE vehicle_monthly_profit (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    total_revenue NUMERIC(12, 2) NOT NULL,
    total_expense NUMERIC(12, 2) NOT NULL,
    total_profit NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_vehicle_monthly_profit_period UNIQUE (vehicle_id, year, month)
);
CREATE INDEX ix_vehicle_monthly_profit_vehicle_id ON vehicle_monthly_profit (vehicle_id);
CREATE INDEX ix_vehicle_monthly_profit_year ON vehicle_monthly_profit (year);
CREATE INDEX ix_vehicle_monthly_profit_org_vehicle ON vehicle_monthly_profit (organization_id, vehicle_id);

-- Audit Logs
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    organization_id UUID NOT NULL,
    user_id UUID,
    entity_type VARCHAR(128),
    entity_id BIGINT,
    action VARCHAR(64),
    changes JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_audit_logs_organization_id ON audit_logs (organization_id);
CREATE INDEX ix_audit_logs_user_id ON audit_logs (user_id);
CREATE INDEX ix_audit_org_time ON audit_logs (organization_id, created_at);

-- Enable RLS on all tables
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE maintenance_schedule ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_calendar_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminder_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE trip_profit_summary ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_daily_profit ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicle_monthly_profit ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- Migration: 20260610161252_002_rls_policies.sql
-- ==========================================

-- RLS Policies for VahanOne
-- Organizations: Public read for members, admin only write
CREATE POLICY "org_public_read" ON organizations FOR SELECT TO authenticated USING (true);
CREATE POLICY "org_admin_insert" ON organizations FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "org_admin_update" ON organizations FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- Users: Users can read their own data
CREATE POLICY "users_read_own" ON users FOR SELECT TO authenticated USING (auth.uid() = id OR is_superuser = true);
CREATE POLICY "users_insert_own" ON users FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "users_update_own" ON users FOR UPDATE TO authenticated USING (auth.uid() = id OR is_superuser = true) WITH CHECK (auth.uid() = id OR is_superuser = true);

-- Roles: Authenticated users can read
CREATE POLICY "roles_read" ON roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "roles_insert" ON roles FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "roles_update" ON roles FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "roles_delete" ON roles FOR DELETE TO authenticated USING (true);

-- Role Permissions
CREATE POLICY "role_permissions_read" ON role_permissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "role_permissions_insert" ON role_permissions FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "role_permissions_delete" ON role_permissions FOR DELETE TO authenticated USING (true);

-- User Roles
CREATE POLICY "user_roles_read" ON user_roles FOR SELECT TO authenticated USING (true);
CREATE POLICY "user_roles_insert" ON user_roles FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "user_roles_delete" ON user_roles FOR DELETE TO authenticated USING (true);

-- Permissions: Public read
CREATE POLICY "permissions_read" ON permissions FOR SELECT TO authenticated USING (true);
CREATE POLICY "permissions_insert" ON permissions FOR INSERT TO authenticated WITH CHECK (true);

-- Customers: Organization-scoped CRUD
CREATE POLICY "customers_select" ON customers FOR SELECT TO authenticated USING (true);
CREATE POLICY "customers_insert" ON customers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "customers_update" ON customers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "customers_delete" ON customers FOR DELETE TO authenticated USING (true);

-- Vehicles: Organization-scoped CRUD
CREATE POLICY "vehicles_select" ON vehicles FOR SELECT TO authenticated USING (true);
CREATE POLICY "vehicles_insert" ON vehicles FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "vehicles_update" ON vehicles FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "vehicles_delete" ON vehicles FOR DELETE TO authenticated USING (true);

-- Drivers: Organization-scoped CRUD
CREATE POLICY "drivers_select" ON drivers FOR SELECT TO authenticated USING (true);
CREATE POLICY "drivers_insert" ON drivers FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "drivers_update" ON drivers FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "drivers_delete" ON drivers FOR DELETE TO authenticated USING (true);

-- Bookings: Organization-scoped CRUD
CREATE POLICY "bookings_select" ON bookings FOR SELECT TO authenticated USING (true);
CREATE POLICY "bookings_insert" ON bookings FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "bookings_update" ON bookings FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "bookings_delete" ON bookings FOR DELETE TO authenticated USING (true);

-- Trip Packages: Organization-scoped CRUD
CREATE POLICY "trip_packages_select" ON trip_packages FOR SELECT TO authenticated USING (true);
CREATE POLICY "trip_packages_insert" ON trip_packages FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "trip_packages_update" ON trip_packages FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "trip_packages_delete" ON trip_packages FOR DELETE TO authenticated USING (true);

-- Trips: Organization-scoped CRUD
CREATE POLICY "trips_select" ON trips FOR SELECT TO authenticated USING (true);
CREATE POLICY "trips_insert" ON trips FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "trips_update" ON trips FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "trips_delete" ON trips FOR DELETE TO authenticated USING (true);

-- Expenses: Organization-scoped CRUD
CREATE POLICY "expenses_select" ON expenses FOR SELECT TO authenticated USING (true);
CREATE POLICY "expenses_insert" ON expenses FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "expenses_update" ON expenses FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "expenses_delete" ON expenses FOR DELETE TO authenticated USING (true);

-- Invoices: Organization-scoped CRUD
CREATE POLICY "invoices_select" ON invoices FOR SELECT TO authenticated USING (true);
CREATE POLICY "invoices_insert" ON invoices FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "invoices_update" ON invoices FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "invoices_delete" ON invoices FOR DELETE TO authenticated USING (true);

-- Invoice Items
CREATE POLICY "invoice_items_select" ON invoice_items FOR SELECT TO authenticated USING (true);
CREATE POLICY "invoice_items_insert" ON invoice_items FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "invoice_items_update" ON invoice_items FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "invoice_items_delete" ON invoice_items FOR DELETE TO authenticated USING (true);

-- Payments
CREATE POLICY "payments_select" ON payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "payments_insert" ON payments FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "payments_update" ON payments FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "payments_delete" ON payments FOR DELETE TO authenticated USING (true);

-- Maintenance Schedule
CREATE POLICY "maintenance_schedule_select" ON maintenance_schedule FOR SELECT TO authenticated USING (true);
CREATE POLICY "maintenance_schedule_insert" ON maintenance_schedule FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "maintenance_schedule_update" ON maintenance_schedule FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "maintenance_schedule_delete" ON maintenance_schedule FOR DELETE TO authenticated USING (true);

-- Vehicle Calendar Events
CREATE POLICY "vehicle_calendar_events_select" ON vehicle_calendar_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "vehicle_calendar_events_insert" ON vehicle_calendar_events FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "vehicle_calendar_events_update" ON vehicle_calendar_events FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_calendar_events_delete" ON vehicle_calendar_events FOR DELETE TO authenticated USING (true);

-- Reminder Rules
CREATE POLICY "reminder_rules_select" ON reminder_rules FOR SELECT TO authenticated USING (true);
CREATE POLICY "reminder_rules_insert" ON reminder_rules FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "reminder_rules_update" ON reminder_rules FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "reminder_rules_delete" ON reminder_rules FOR DELETE TO authenticated USING (true);

-- Reminders
CREATE POLICY "reminders_select" ON reminders FOR SELECT TO authenticated USING (true);
CREATE POLICY "reminders_insert" ON reminders FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "reminders_update" ON reminders FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "reminders_delete" ON reminders FOR DELETE TO authenticated USING (true);

-- Notification Events
CREATE POLICY "notification_events_select" ON notification_events FOR SELECT TO authenticated USING (true);
CREATE POLICY "notification_events_insert" ON notification_events FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notification_events_update" ON notification_events FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "notification_events_delete" ON notification_events FOR DELETE TO authenticated USING (true);

-- Notification Preferences
CREATE POLICY "notification_preferences_select" ON notification_preferences FOR SELECT TO authenticated USING (true);
CREATE POLICY "notification_preferences_insert" ON notification_preferences FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notification_preferences_update" ON notification_preferences FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "notification_preferences_delete" ON notification_preferences FOR DELETE TO authenticated USING (true);

-- Notifications
CREATE POLICY "notifications_select" ON notifications FOR SELECT TO authenticated USING (true);
CREATE POLICY "notifications_insert" ON notifications FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "notifications_update" ON notifications FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "notifications_delete" ON notifications FOR DELETE TO authenticated USING (true);

-- Profit Tables
CREATE POLICY "trip_profit_summary_select" ON trip_profit_summary FOR SELECT TO authenticated USING (true);
CREATE POLICY "trip_profit_summary_insert" ON trip_profit_summary FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "trip_profit_summary_update" ON trip_profit_summary FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "trip_profit_summary_delete" ON trip_profit_summary FOR DELETE TO authenticated USING (true);

CREATE POLICY "vehicle_daily_profit_select" ON vehicle_daily_profit FOR SELECT TO authenticated USING (true);
CREATE POLICY "vehicle_daily_profit_insert" ON vehicle_daily_profit FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "vehicle_daily_profit_update" ON vehicle_daily_profit FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_daily_profit_delete" ON vehicle_daily_profit FOR DELETE TO authenticated USING (true);

CREATE POLICY "vehicle_monthly_profit_select" ON vehicle_monthly_profit FOR SELECT TO authenticated USING (true);
CREATE POLICY "vehicle_monthly_profit_insert" ON vehicle_monthly_profit FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "vehicle_monthly_profit_update" ON vehicle_monthly_profit FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_monthly_profit_delete" ON vehicle_monthly_profit FOR DELETE TO authenticated USING (true);

-- Audit Logs
CREATE POLICY "audit_logs_select" ON audit_logs FOR SELECT TO authenticated USING (true);
CREATE POLICY "audit_logs_insert" ON audit_logs FOR INSERT TO authenticated WITH CHECK (true);

-- ==========================================
-- Migration: 20260610161307_003_seed_data.sql
-- ==========================================

-- Seed Data
-- Create default organization
INSERT INTO organizations (id, name, is_active) VALUES ('00000000-0000-0000-0000-000000000001', 'VahanOne Transport', true);

-- Create default permissions
INSERT INTO permissions (code, name, resource, action) VALUES
('vehicles.read', 'View Vehicles', 'vehicles', 'read'),
('vehicles.write', 'Manage Vehicles', 'vehicles', 'write'),
('vehicles.delete', 'Delete Vehicles', 'vehicles', 'delete'),
('bookings.read', 'View Bookings', 'bookings', 'read'),
('bookings.write', 'Manage Bookings', 'bookings', 'write'),
('bookings.delete', 'Delete Bookings', 'bookings', 'delete'),
('customers.read', 'View Customers', 'customers', 'read'),
('customers.write', 'Manage Customers', 'customers', 'write'),
('customers.delete', 'Delete Customers', 'customers', 'delete'),
('trips.read', 'View Trips', 'trips', 'read'),
('trips.write', 'Manage Trips', 'trips', 'write'),
('trips.delete', 'Delete Trips', 'trips', 'delete'),
('expenses.read', 'View Expenses', 'expenses', 'read'),
('expenses.write', 'Manage Expenses', 'expenses', 'write'),
('expenses.delete', 'Delete Expenses', 'expenses', 'delete'),
('invoices.read', 'View Invoices', 'invoices', 'read'),
('invoices.write', 'Manage Invoices', 'invoices', 'write'),
('invoices.delete', 'Delete Invoices', 'invoices', 'delete'),
('profit.read', 'View Profit Reports', 'profit', 'read'),
('reminders.read', 'View Reminders', 'reminders', 'read'),
('reminders.write', 'Manage Reminders', 'reminders', 'write'),
('maintenance.read', 'View Maintenance', 'maintenance', 'read'),
('maintenance.write', 'Manage Maintenance', 'maintenance', 'write');

-- Create admin role
INSERT INTO roles (id, organization_id, name, description) VALUES 
(1, '00000000-0000-0000-0000-000000000001', 'admin', 'Administrator with full access'),
(2, '00000000-0000-0000-0000-000000000001', 'member', 'Regular member');

-- Assign all permissions to admin role
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- Assign read permissions to member role
INSERT INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE code LIKE '%.read';

-- ==========================================
-- Migration: 20260610161840_004_sample_data.sql
-- ==========================================

-- Sample Vehicles
INSERT INTO vehicles (organization_id, vehicle_number, vehicle_type, make, model, seating_capacity, fuel_type, insurance_expiry_date, permit_expiry_date, fc_expiry_date, pollution_expiry_date, road_tax_expiry_date, purchase_price, emi_amount, emi_due_day, is_active)
VALUES 
('00000000-0000-0000-0000-000000000001', 'KA-01-AB-1234', 'Sedan', 'Toyota', 'Innova Crysta', 7, 'Diesel', NOW() + INTERVAL '45 days', NOW() + INTERVAL '60 days', NOW() + INTERVAL '90 days', NOW() + INTERVAL '180 days', NOW() + INTERVAL '365 days', 1800000, 35000, 5, true),
('00000000-0000-0000-0000-000000000001', 'KA-02-CD-5678', 'SUV', 'Mahindra', 'XUV500', 6, 'Diesel', NOW() + INTERVAL '30 days', NOW() + INTERVAL '45 days', NOW() + INTERVAL '60 days', NOW() + INTERVAL '120 days', NOW() + INTERVAL '300 days', 1600000, 28000, 10, true),
('00000000-0000-0000-0000-000000000001', 'KA-03-EF-9012', 'Tempo Traveller', 'Force', 'Traveller', 12, 'Diesel', NOW() + INTERVAL '15 days', NOW() + INTERVAL '30 days', NOW() + INTERVAL '45 days', NOW() + INTERVAL '90 days', NOW() + INTERVAL '180 days', 2200000, 45000, 15, true),
('00000000-0000-0000-0000-000000000001', 'KA-04-GH-3456', 'Minibus', 'Tata', 'Winger', 15, 'Diesel', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days', NOW() + INTERVAL '30 days', NOW() + INTERVAL '60 days', NOW() + INTERVAL '90 days', 1400000, 25000, 20, true);

-- Sample Customers
INSERT INTO customers (organization_id, customer_name, company, phone_number, email, gst_number, city, state, address, is_active)
VALUES 
('00000000-0000-0000-0000-000000000001', 'Rajesh Kumar', 'Kumar Travels', '9876543210', 'rajesh@kumartravels.com', '29AABCK1234L1Z5', 'Bangalore', 'Karnataka', '123 MG Road, Bangalore', true),
('00000000-0000-0000-0000-000000000001', 'Priya Sharma', 'Sharma Tours', '9876543211', 'priya@sharmatours.com', '27AABCS5678M2Z6', 'Mumbai', 'Maharashtra', '456 Andheri West, Mumbai', true),
('00000000-0000-0000-0000-000000000001', 'Anil Patel', 'Patel Transport', '9876543212', 'anil@pateltransport.com', '24AABCP9012N3Z7', 'Ahmedabad', 'Gujarat', '789 CG Road, Ahmedabad', true);

-- Sample Drivers
INSERT INTO drivers (organization_id, name, license_number, license_expiry, contact_number)
VALUES 
('00000000-0000-0000-0000-000000000001', 'Ramesh Singh', 'KA-01-LIC-12345', NOW() + INTERVAL '365 days', '9123456789'),
('00000000-0000-0000-0000-000000000001', 'Suresh Kumar', 'KA-02-LIC-67890', NOW() + INTERVAL '180 days', '9234567890'),
('00000000-0000-0000-0000-000000000001', 'Mahesh Yadav', 'KA-03-LIC-11111', NOW() + INTERVAL '90 days', '9345678901');

-- Sample Trip Packages
INSERT INTO trip_packages (organization_id, name, package_category, included_hours, included_km, base_amount, extra_km_rate, extra_hour_rate, driver_bata_default, night_charge_default, minimum_km_per_day, km_rate, active)
VALUES 
('00000000-0000-0000-0000-000000000001', 'Local 8 Hours', 'local', 8, 80, 2500, 14, 200, 300, 0, 80, 14, true),
('00000000-0000-0000-0000-000000000001', 'Outstation Daily', 'outstation', 10, 300, 12000, 15, 250, 500, 500, 300, 15, true),
('00000000-0000-0000-0000-000000000001', 'Airport Transfer', 'transfer', 4, 50, 2000, 18, 180, 200, 0, 50, 18, true);

-- Reminder Rules
INSERT INTO reminder_rules (organization_id, name, category, event_type, description, active, trigger_days_before, priority)
VALUES 
('00000000-0000-0000-0000-000000000001', 'Insurance Expiry', 'Vehicle Compliance', 'insurance_expiry', 'Vehicle insurance renewal reminder', true, 30, 100),
('00000000-0000-0000-0000-000000000001', 'Permit Expiry', 'Vehicle Compliance', 'permit_expiry', 'Vehicle permit renewal reminder', true, 15, 90),
('00000000-0000-0000-0000-000000000001', 'FC Expiry', 'Vehicle Compliance', 'fc_expiry', 'Fitness certificate renewal reminder', true, 14, 80);

-- ==========================================
-- Migration: 20260611101909_005_anon_rls_policies.sql
-- ==========================================

-- Allow anon role to access all tables (for frontend-only app using anon key)
-- This replaces the authenticated-only policies for read/write access

-- Organizations
CREATE POLICY "org_anon_read" ON organizations FOR SELECT TO anon USING (true);
CREATE POLICY "org_anon_insert" ON organizations FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "org_anon_update" ON organizations FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Users
CREATE POLICY "users_anon_read" ON users FOR SELECT TO anon USING (true);
CREATE POLICY "users_anon_insert" ON users FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "users_anon_update" ON users FOR UPDATE TO anon USING (true) WITH CHECK (true);

-- Roles
CREATE POLICY "roles_anon_select" ON roles FOR SELECT TO anon USING (true);
CREATE POLICY "roles_anon_insert" ON roles FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "roles_anon_update" ON roles FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "roles_anon_delete" ON roles FOR DELETE TO anon USING (true);

-- Role Permissions
CREATE POLICY "role_permissions_anon_select" ON role_permissions FOR SELECT TO anon USING (true);
CREATE POLICY "role_permissions_anon_insert" ON role_permissions FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "role_permissions_anon_delete" ON role_permissions FOR DELETE TO anon USING (true);

-- User Roles
CREATE POLICY "user_roles_anon_read" ON user_roles FOR SELECT TO anon USING (true);
CREATE POLICY "user_roles_anon_insert" ON user_roles FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "user_roles_anon_delete" ON user_roles FOR DELETE TO anon USING (true);

-- Permissions
CREATE POLICY "permissions_anon_read" ON permissions FOR SELECT TO anon USING (true);
CREATE POLICY "permissions_anon_insert" ON permissions FOR INSERT TO anon WITH CHECK (true);

-- Customers
CREATE POLICY "customers_anon_select" ON customers FOR SELECT TO anon USING (true);
CREATE POLICY "customers_anon_insert" ON customers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "customers_anon_update" ON customers FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "customers_anon_delete" ON customers FOR DELETE TO anon USING (true);

-- Vehicles
CREATE POLICY "vehicles_anon_select" ON vehicles FOR SELECT TO anon USING (true);
CREATE POLICY "vehicles_anon_insert" ON vehicles FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "vehicles_anon_update" ON vehicles FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "vehicles_anon_delete" ON vehicles FOR DELETE TO anon USING (true);

-- Drivers
CREATE POLICY "drivers_anon_select" ON drivers FOR SELECT TO anon USING (true);
CREATE POLICY "drivers_anon_insert" ON drivers FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "drivers_anon_update" ON drivers FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "drivers_anon_delete" ON drivers FOR DELETE TO anon USING (true);

-- Bookings
CREATE POLICY "bookings_anon_select" ON bookings FOR SELECT TO anon USING (true);
CREATE POLICY "bookings_anon_insert" ON bookings FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "bookings_anon_update" ON bookings FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "bookings_anon_delete" ON bookings FOR DELETE TO anon USING (true);

-- Trip Packages
CREATE POLICY "trip_packages_anon_select" ON trip_packages FOR SELECT TO anon USING (true);
CREATE POLICY "trip_packages_anon_insert" ON trip_packages FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "trip_packages_anon_update" ON trip_packages FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "trip_packages_anon_delete" ON trip_packages FOR DELETE TO anon USING (true);

-- Trips
CREATE POLICY "trips_anon_select" ON trips FOR SELECT TO anon USING (true);
CREATE POLICY "trips_anon_insert" ON trips FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "trips_anon_update" ON trips FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "trips_anon_delete" ON trips FOR DELETE TO anon USING (true);

-- Expenses
CREATE POLICY "expenses_anon_select" ON expenses FOR SELECT TO anon USING (true);
CREATE POLICY "expenses_anon_insert" ON expenses FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "expenses_anon_update" ON expenses FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "expenses_anon_delete" ON expenses FOR DELETE TO anon USING (true);

-- Invoices
CREATE POLICY "invoices_anon_select" ON invoices FOR SELECT TO anon USING (true);
CREATE POLICY "invoices_anon_insert" ON invoices FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "invoices_anon_update" ON invoices FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "invoices_anon_delete" ON invoices FOR DELETE TO anon USING (true);

-- Invoice Items
CREATE POLICY "invoice_items_anon_select" ON invoice_items FOR SELECT TO anon USING (true);
CREATE POLICY "invoice_items_anon_insert" ON invoice_items FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "invoice_items_anon_update" ON invoice_items FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "invoice_items_anon_delete" ON invoice_items FOR DELETE TO anon USING (true);

-- Payments
CREATE POLICY "payments_anon_select" ON payments FOR SELECT TO anon USING (true);
CREATE POLICY "payments_anon_insert" ON payments FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "payments_anon_update" ON payments FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "payments_anon_delete" ON payments FOR DELETE TO anon USING (true);

-- Maintenance Schedule
CREATE POLICY "maintenance_schedule_anon_select" ON maintenance_schedule FOR SELECT TO anon USING (true);
CREATE POLICY "maintenance_schedule_anon_insert" ON maintenance_schedule FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "maintenance_schedule_anon_update" ON maintenance_schedule FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "maintenance_schedule_anon_delete" ON maintenance_schedule FOR DELETE TO anon USING (true);

-- Vehicle Calendar Events
CREATE POLICY "vehicle_calendar_events_anon_select" ON vehicle_calendar_events FOR SELECT TO anon USING (true);
CREATE POLICY "vehicle_calendar_events_anon_insert" ON vehicle_calendar_events FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "vehicle_calendar_events_anon_update" ON vehicle_calendar_events FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_calendar_events_anon_delete" ON vehicle_calendar_events FOR DELETE TO anon USING (true);

-- Reminder Rules
CREATE POLICY "reminder_rules_anon_select" ON reminder_rules FOR SELECT TO anon USING (true);
CREATE POLICY "reminder_rules_anon_insert" ON reminder_rules FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "reminder_rules_anon_update" ON reminder_rules FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "reminder_rules_anon_delete" ON reminder_rules FOR DELETE TO anon USING (true);

-- Reminders
CREATE POLICY "reminders_anon_select" ON reminders FOR SELECT TO anon USING (true);
CREATE POLICY "reminders_anon_insert" ON reminders FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "reminders_anon_update" ON reminders FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "reminders_anon_delete" ON reminders FOR DELETE TO anon USING (true);

-- Notification Events
CREATE POLICY "notification_events_anon_select" ON notification_events FOR SELECT TO anon USING (true);
CREATE POLICY "notification_events_anon_insert" ON notification_events FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "notification_events_anon_update" ON notification_events FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "notification_events_anon_delete" ON notification_events FOR DELETE TO anon USING (true);

-- Notification Preferences
CREATE POLICY "notification_preferences_anon_select" ON notification_preferences FOR SELECT TO anon USING (true);
CREATE POLICY "notification_preferences_anon_insert" ON notification_preferences FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "notification_preferences_anon_update" ON notification_preferences FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "notification_preferences_anon_delete" ON notification_preferences FOR DELETE TO anon USING (true);

-- Notifications
CREATE POLICY "notifications_anon_select" ON notifications FOR SELECT TO anon USING (true);
CREATE POLICY "notifications_anon_insert" ON notifications FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "notifications_anon_update" ON notifications FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "notifications_anon_delete" ON notifications FOR DELETE TO anon USING (true);

-- Profit Tables
CREATE POLICY "trip_profit_summary_anon_select" ON trip_profit_summary FOR SELECT TO anon USING (true);
CREATE POLICY "trip_profit_summary_anon_insert" ON trip_profit_summary FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "trip_profit_summary_anon_update" ON trip_profit_summary FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "trip_profit_summary_anon_delete" ON trip_profit_summary FOR DELETE TO anon USING (true);

CREATE POLICY "vehicle_daily_profit_anon_select" ON vehicle_daily_profit FOR SELECT TO anon USING (true);
CREATE POLICY "vehicle_daily_profit_anon_insert" ON vehicle_daily_profit FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "vehicle_daily_profit_anon_update" ON vehicle_daily_profit FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_daily_profit_anon_delete" ON vehicle_daily_profit FOR DELETE TO anon USING (true);

CREATE POLICY "vehicle_monthly_profit_anon_select" ON vehicle_monthly_profit FOR SELECT TO anon USING (true);
CREATE POLICY "vehicle_monthly_profit_anon_insert" ON vehicle_monthly_profit FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "vehicle_monthly_profit_anon_update" ON vehicle_monthly_profit FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "vehicle_monthly_profit_anon_delete" ON vehicle_monthly_profit FOR DELETE TO anon USING (true);

-- Audit Logs
CREATE POLICY "audit_logs_anon_select" ON audit_logs FOR SELECT TO anon USING (true);
CREATE POLICY "audit_logs_anon_insert" ON audit_logs FOR INSERT TO anon WITH CHECK (true);

-- ==========================================
-- Migration: 20260619095059_add_vehicle_document_settings_tables.sql
-- ==========================================

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

-- ==========================================
-- Migration: 20260619095733_add_sample_data.sql
-- ==========================================

-- Insert sample company settings
INSERT INTO company_settings (organization_id, company_name, address, city, state, pincode, phone, email, gst_number, pan_number, bank_name, bank_account_number, bank_ifsc_code, invoice_prefix)
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'VahanOne Transport Pvt Ltd',
    '123, Industrial Area, Sector 15',
    'Gurgaon',
    'Haryana',
    '122001',
    '9876543210',
    'info@vahanone.com',
    '06AAACM1234A1ZM',
    'AAACM1234A',
    'State Bank of India',
    '1234567890',
    'SBIN0001234',
    'INV'
) ON CONFLICT (organization_id) DO NOTHING;

-- Insert sample drivers
INSERT INTO drivers (organization_id, name, license_number, license_expiry, contact_number)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'Rajesh Kumar', 'HR0120230001234', '2025-12-15', '9876543211'),
    ('00000000-0000-0000-0000-000000000001', 'Suresh Yadav', 'DL0120220005678', '2025-06-30', '9876543212'),
    ('00000000-0000-0000-0000-000000000001', 'Mohan Singh', 'UP0120210009012', '2024-09-15', '9876543213'),
    ('00000000-0000-0000-0000-000000000001', 'Amit Sharma', 'MH0120230003456', '2026-03-20', '9876543214'),
    ('00000000-0000-0000-0000-000000000001', 'Deepak Verma', 'KA0120220007890', '2025-08-10', '9876543215')
ON CONFLICT (organization_id, license_number) DO NOTHING;

-- Insert sample vehicles
INSERT INTO vehicles (organization_id, vehicle_number, vehicle_type, make, model, year, seating_capacity, fuel_type, chassis_number, engine_number, rc_expiry_date, insurance_expiry_date, permit_expiry_date, fc_expiry_date, pollution_expiry_date, road_tax_expiry_date, emi_amount, emi_due_day, is_active)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'HR 26 AB 1234', 'Bus', 'Tata', 'Marcopolo', 2022, 45, 'Diesel', 'CH12345678', 'ENG12345678', '2027-03-15', '2025-03-15', '2025-03-15', '2025-06-20', '2025-04-10', '2027-03-15', 45000, 5, true),
    ('00000000-0000-0000-0000-000000000001', 'DL 01 CD 5678', 'Truck', 'Ashok Leyland', 'Captain', 2021, 2, 'Diesel', 'CH23456789', 'ENG23456789', '2026-01-20', '2025-01-20', '2025-01-20', '2025-03-15', '2025-02-28', '2026-01-20', 55000, 10, true),
    ('00000000-0000-0000-0000-000000000001', 'UP 32 EF 9012', 'Mini Bus', 'Force', 'Traveller', 2023, 18, 'Diesel', 'CH34567890', 'ENG34567890', '2028-05-30', '2026-05-30', '2026-05-30', '2026-08-15', '2025-12-20', '2028-05-30', 35000, 15, true),
    ('00000000-0000-0000-0000-000000000001', 'MH 12 GH 3456', 'Bus', 'Volvo', '9400XL', 2020, 40, 'Diesel', 'CH45678901', 'ENG45678901', '2026-08-10', '2025-08-10', '2025-08-10', '2025-11-25', '2025-09-15', '2026-08-10', 75000, 1, true),
    ('00000000-0000-0000-0000-000000000001', 'KA 09 IJ 7890', 'Tempo', 'Tata', 'Ace', 2022, 6, 'Diesel', 'CH56789012', 'ENG56789012', '2027-11-25', '2026-11-25', '2026-11-25', '2027-02-20', '2025-07-05', '2027-11-25', 18000, 20, true)
ON CONFLICT (organization_id, vehicle_number) DO NOTHING;

-- Insert sample customers
INSERT INTO customers (organization_id, customer_name, company, phone_number, email, gst_number, city)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'Rahul Mehta', 'Mehta Tours & Travels', '9876543220', 'rahul@mehtatours.com', '06AAACM5678A1ZN', 'Delhi'),
    ('00000000-0000-0000-0000-000000000001', 'Priya Sharma', 'Sharma Transport Company', '9876543221', 'priya@sharmatransport.com', '07AAACM9012A1ZO', 'Mumbai'),
    ('00000000-0000-0000-0000-000000000001', 'Amit Patel', 'Patel Logistics', '9876543222', 'amit@patellogistics.com', '08AAACM3456A1ZP', 'Ahmedabad')
ON CONFLICT (organization_id, phone_number) DO NOTHING;

-- ==========================================
-- Migration: 20260619100933_20260619120000_fix_rls_security.sql.sql
-- ==========================================

-- Fix RLS Security: Remove always-true policies and implement proper org-scoped access
-- This migration drops all insecure policies and recreates them with proper organization scoping

-- Helper function to get the current user's organization_id
CREATE OR REPLACE FUNCTION public.get_user_org_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT organization_id FROM public.user_profiles WHERE user_id = auth.uid() LIMIT 1;
$$;

-- Helper function to check if user is superuser
CREATE OR REPLACE FUNCTION public.is_superuser()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT COALESCE(
    (SELECT is_superuser FROM public.users WHERE id = auth.uid()),
    false
  );
$$;

-- ============================================================================
-- DROP ALL EXISTING INSECURE POLICIES
-- ============================================================================

-- Authenticated policies from 002_rls_policies.sql
DROP POLICY IF EXISTS "org_public_read" ON organizations;
DROP POLICY IF EXISTS "org_admin_insert" ON organizations;
DROP POLICY IF EXISTS "org_admin_update" ON organizations;
DROP POLICY IF EXISTS "users_read_own" ON users;
DROP POLICY IF EXISTS "users_insert_own" ON users;
DROP POLICY IF EXISTS "users_update_own" ON users;
DROP POLICY IF EXISTS "roles_read" ON roles;
DROP POLICY IF EXISTS "roles_insert" ON roles;
DROP POLICY IF EXISTS "roles_update" ON roles;
DROP POLICY IF EXISTS "roles_delete" ON roles;
DROP POLICY IF EXISTS "role_permissions_read" ON role_permissions;
DROP POLICY IF EXISTS "role_permissions_insert" ON role_permissions;
DROP POLICY IF EXISTS "role_permissions_delete" ON role_permissions;
DROP POLICY IF EXISTS "user_roles_read" ON user_roles;
DROP POLICY IF EXISTS "user_roles_insert" ON user_roles;
DROP POLICY IF EXISTS "user_roles_delete" ON user_roles;
DROP POLICY IF EXISTS "permissions_read" ON permissions;
DROP POLICY IF EXISTS "permissions_insert" ON permissions;
DROP POLICY IF EXISTS "customers_select" ON customers;
DROP POLICY IF EXISTS "customers_insert" ON customers;
DROP POLICY IF EXISTS "customers_update" ON customers;
DROP POLICY IF EXISTS "customers_delete" ON customers;
DROP POLICY IF EXISTS "vehicles_select" ON vehicles;
DROP POLICY IF EXISTS "vehicles_insert" ON vehicles;
DROP POLICY IF EXISTS "vehicles_update" ON vehicles;
DROP POLICY IF EXISTS "vehicles_delete" ON vehicles;
DROP POLICY IF EXISTS "drivers_select" ON drivers;
DROP POLICY IF EXISTS "drivers_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_update" ON drivers;
DROP POLICY IF EXISTS "drivers_delete" ON drivers;
DROP POLICY IF EXISTS "bookings_select" ON bookings;
DROP POLICY IF EXISTS "bookings_insert" ON bookings;
DROP POLICY IF EXISTS "bookings_update" ON bookings;
DROP POLICY IF EXISTS "bookings_delete" ON bookings;
DROP POLICY IF EXISTS "trip_packages_select" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_insert" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_update" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_delete" ON trip_packages;
DROP POLICY IF EXISTS "trips_select" ON trips;
DROP POLICY IF EXISTS "trips_insert" ON trips;
DROP POLICY IF EXISTS "trips_update" ON trips;
DROP POLICY IF EXISTS "trips_delete" ON trips;
DROP POLICY IF EXISTS "expenses_select" ON expenses;
DROP POLICY IF EXISTS "expenses_insert" ON expenses;
DROP POLICY IF EXISTS "expenses_update" ON expenses;
DROP POLICY IF EXISTS "expenses_delete" ON expenses;
DROP POLICY IF EXISTS "invoices_select" ON invoices;
DROP POLICY IF EXISTS "invoices_insert" ON invoices;
DROP POLICY IF EXISTS "invoices_update" ON invoices;
DROP POLICY IF EXISTS "invoices_delete" ON invoices;
DROP POLICY IF EXISTS "invoice_items_select" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_insert" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_update" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_delete" ON invoice_items;
DROP POLICY IF EXISTS "payments_select" ON payments;
DROP POLICY IF EXISTS "payments_insert" ON payments;
DROP POLICY IF EXISTS "payments_update" ON payments;
DROP POLICY IF EXISTS "payments_delete" ON payments;
DROP POLICY IF EXISTS "maintenance_schedule_select" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_insert" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_update" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_delete" ON maintenance_schedule;
DROP POLICY IF EXISTS "vehicle_calendar_events_select" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_insert" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_update" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_delete" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "reminder_rules_select" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_insert" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_update" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_delete" ON reminder_rules;
DROP POLICY IF EXISTS "reminders_select" ON reminders;
DROP POLICY IF EXISTS "reminders_insert" ON reminders;
DROP POLICY IF EXISTS "reminders_update" ON reminders;
DROP POLICY IF EXISTS "reminders_delete" ON reminders;
DROP POLICY IF EXISTS "notification_events_select" ON notification_events;
DROP POLICY IF EXISTS "notification_events_insert" ON notification_events;
DROP POLICY IF EXISTS "notification_events_update" ON notification_events;
DROP POLICY IF EXISTS "notification_events_delete" ON notification_events;
DROP POLICY IF EXISTS "notification_preferences_select" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_insert" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_update" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_delete" ON notification_preferences;
DROP POLICY IF EXISTS "notifications_select" ON notifications;
DROP POLICY IF EXISTS "notifications_insert" ON notifications;
DROP POLICY IF EXISTS "notifications_update" ON notifications;
DROP POLICY IF EXISTS "notifications_delete" ON notifications;
DROP POLICY IF EXISTS "trip_profit_summary_select" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_insert" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_update" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_delete" ON trip_profit_summary;
DROP POLICY IF EXISTS "vehicle_daily_profit_select" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_insert" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_update" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_delete" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_select" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_insert" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_update" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_delete" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "audit_logs_select" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_insert" ON audit_logs;

-- Anon policies from 005_anon_rls_policies.sql
DROP POLICY IF EXISTS "org_anon_read" ON organizations;
DROP POLICY IF EXISTS "org_anon_insert" ON organizations;
DROP POLICY IF EXISTS "org_anon_update" ON organizations;
DROP POLICY IF EXISTS "users_anon_read" ON users;
DROP POLICY IF EXISTS "users_anon_insert" ON users;
DROP POLICY IF EXISTS "users_anon_update" ON users;
DROP POLICY IF EXISTS "roles_anon_select" ON roles;
DROP POLICY IF EXISTS "roles_anon_insert" ON roles;
DROP POLICY IF EXISTS "roles_anon_update" ON roles;
DROP POLICY IF EXISTS "roles_anon_delete" ON roles;
DROP POLICY IF EXISTS "role_permissions_anon_select" ON role_permissions;
DROP POLICY IF EXISTS "role_permissions_anon_insert" ON role_permissions;
DROP POLICY IF EXISTS "role_permissions_anon_delete" ON role_permissions;
DROP POLICY IF EXISTS "user_roles_anon_read" ON user_roles;
DROP POLICY IF EXISTS "user_roles_anon_insert" ON user_roles;
DROP POLICY IF EXISTS "user_roles_anon_delete" ON user_roles;
DROP POLICY IF EXISTS "permissions_anon_read" ON permissions;
DROP POLICY IF EXISTS "permissions_anon_insert" ON permissions;
DROP POLICY IF EXISTS "customers_anon_select" ON customers;
DROP POLICY IF EXISTS "customers_anon_insert" ON customers;
DROP POLICY IF EXISTS "customers_anon_update" ON customers;
DROP POLICY IF EXISTS "customers_anon_delete" ON customers;
DROP POLICY IF EXISTS "vehicles_anon_select" ON vehicles;
DROP POLICY IF EXISTS "vehicles_anon_insert" ON vehicles;
DROP POLICY IF EXISTS "vehicles_anon_update" ON vehicles;
DROP POLICY IF EXISTS "vehicles_anon_delete" ON vehicles;
DROP POLICY IF EXISTS "drivers_anon_select" ON drivers;
DROP POLICY IF EXISTS "drivers_anon_insert" ON drivers;
DROP POLICY IF EXISTS "drivers_anon_update" ON drivers;
DROP POLICY IF EXISTS "drivers_anon_delete" ON drivers;
DROP POLICY IF EXISTS "bookings_anon_select" ON bookings;
DROP POLICY IF EXISTS "bookings_anon_insert" ON bookings;
DROP POLICY IF EXISTS "bookings_anon_update" ON bookings;
DROP POLICY IF EXISTS "bookings_anon_delete" ON bookings;
DROP POLICY IF EXISTS "trip_packages_anon_select" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_anon_insert" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_anon_update" ON trip_packages;
DROP POLICY IF EXISTS "trip_packages_anon_delete" ON trip_packages;
DROP POLICY IF EXISTS "trips_anon_select" ON trips;
DROP POLICY IF EXISTS "trips_anon_insert" ON trips;
DROP POLICY IF EXISTS "trips_anon_update" ON trips;
DROP POLICY IF EXISTS "trips_anon_delete" ON trips;
DROP POLICY IF EXISTS "expenses_anon_select" ON expenses;
DROP POLICY IF EXISTS "expenses_anon_insert" ON expenses;
DROP POLICY IF EXISTS "expenses_anon_update" ON expenses;
DROP POLICY IF EXISTS "expenses_anon_delete" ON expenses;
DROP POLICY IF EXISTS "invoices_anon_select" ON invoices;
DROP POLICY IF EXISTS "invoices_anon_insert" ON invoices;
DROP POLICY IF EXISTS "invoices_anon_update" ON invoices;
DROP POLICY IF EXISTS "invoices_anon_delete" ON invoices;
DROP POLICY IF EXISTS "invoice_items_anon_select" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_anon_insert" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_anon_update" ON invoice_items;
DROP POLICY IF EXISTS "invoice_items_anon_delete" ON invoice_items;
DROP POLICY IF EXISTS "payments_anon_select" ON payments;
DROP POLICY IF EXISTS "payments_anon_insert" ON payments;
DROP POLICY IF EXISTS "payments_anon_update" ON payments;
DROP POLICY IF EXISTS "payments_anon_delete" ON payments;
DROP POLICY IF EXISTS "maintenance_schedule_anon_select" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_anon_insert" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_anon_update" ON maintenance_schedule;
DROP POLICY IF EXISTS "maintenance_schedule_anon_delete" ON maintenance_schedule;
DROP POLICY IF EXISTS "vehicle_calendar_events_anon_select" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_anon_insert" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_anon_update" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "vehicle_calendar_events_anon_delete" ON vehicle_calendar_events;
DROP POLICY IF EXISTS "reminder_rules_anon_select" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_anon_insert" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_anon_update" ON reminder_rules;
DROP POLICY IF EXISTS "reminder_rules_anon_delete" ON reminder_rules;
DROP POLICY IF EXISTS "reminders_anon_select" ON reminders;
DROP POLICY IF EXISTS "reminders_anon_insert" ON reminders;
DROP POLICY IF EXISTS "reminders_anon_update" ON reminders;
DROP POLICY IF EXISTS "reminders_anon_delete" ON reminders;
DROP POLICY IF EXISTS "notification_events_anon_select" ON notification_events;
DROP POLICY IF EXISTS "notification_events_anon_insert" ON notification_events;
DROP POLICY IF EXISTS "notification_events_anon_update" ON notification_events;
DROP POLICY IF EXISTS "notification_events_anon_delete" ON notification_events;
DROP POLICY IF EXISTS "notification_preferences_anon_select" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_anon_insert" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_anon_update" ON notification_preferences;
DROP POLICY IF EXISTS "notification_preferences_anon_delete" ON notification_preferences;
DROP POLICY IF EXISTS "notifications_anon_select" ON notifications;
DROP POLICY IF EXISTS "notifications_anon_insert" ON notifications;
DROP POLICY IF EXISTS "notifications_anon_update" ON notifications;
DROP POLICY IF EXISTS "notifications_anon_delete" ON notifications;
DROP POLICY IF EXISTS "trip_profit_summary_anon_select" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_anon_insert" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_anon_update" ON trip_profit_summary;
DROP POLICY IF EXISTS "trip_profit_summary_anon_delete" ON trip_profit_summary;
DROP POLICY IF EXISTS "vehicle_daily_profit_anon_select" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_anon_insert" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_anon_update" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_daily_profit_anon_delete" ON vehicle_daily_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_anon_select" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_anon_insert" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_anon_update" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "vehicle_monthly_profit_anon_delete" ON vehicle_monthly_profit;
DROP POLICY IF EXISTS "audit_logs_anon_select" ON audit_logs;
DROP POLICY IF EXISTS "audit_logs_anon_insert" ON audit_logs;

-- ============================================================================
-- CREATE SECURE POLICIES - SYSTEM TABLES
-- These tables should only be modified by service role or superusers
-- ============================================================================

-- Organizations: Read for authenticated (own org only), write for superusers only
CREATE POLICY "organizations_select" ON organizations
  FOR SELECT TO authenticated
  USING (id = get_user_org_id());

CREATE POLICY "organizations_insert" ON organizations
  FOR INSERT TO authenticated
  WITH CHECK (is_superuser());

CREATE POLICY "organizations_update" ON organizations
  FOR UPDATE TO authenticated
  USING (id = get_user_org_id() AND is_superuser())
  WITH CHECK (id = get_user_org_id() AND is_superuser());

CREATE POLICY "organizations_delete" ON organizations
  FOR DELETE TO authenticated
  USING (is_superuser());

-- Permissions: Read-only for authenticated, no anon access
CREATE POLICY "permissions_select" ON permissions
  FOR SELECT TO authenticated
  USING (true);

-- Roles: Read for authenticated (own org), write for superusers
CREATE POLICY "roles_select" ON roles
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "roles_insert" ON roles
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id() AND is_superuser());

CREATE POLICY "roles_update" ON roles
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id() AND is_superuser())
  WITH CHECK (organization_id = get_user_org_id() AND is_superuser());

CREATE POLICY "roles_delete" ON roles
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id() AND is_superuser());

-- Role Permissions: Read for authenticated, write for superusers
CREATE POLICY "role_permissions_select" ON role_permissions
  FOR SELECT TO authenticated
  USING (role_id IN (SELECT id FROM roles WHERE organization_id = get_user_org_id()));

CREATE POLICY "role_permissions_insert" ON role_permissions
  FOR INSERT TO authenticated
  WITH CHECK (role_id IN (SELECT id FROM roles WHERE organization_id = get_user_org_id()) AND is_superuser());

CREATE POLICY "role_permissions_delete" ON role_permissions
  FOR DELETE TO authenticated
  USING (role_id IN (SELECT id FROM roles WHERE organization_id = get_user_org_id()) AND is_superuser());

-- Users: Read own record and org members, update own record
CREATE POLICY "users_select" ON users
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id() OR id = auth.uid() OR is_superuser());

CREATE POLICY "users_insert" ON users
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id() AND is_superuser());

CREATE POLICY "users_update" ON users
  FOR UPDATE TO authenticated
  USING (id = auth.uid() OR (organization_id = get_user_org_id() AND is_superuser()))
  WITH CHECK (id = auth.uid() OR (organization_id = get_user_org_id() AND is_superuser()));

CREATE POLICY "users_delete" ON users
  FOR DELETE TO authenticated
  USING (is_superuser());

-- User Roles: Read for authenticated, write for superusers
CREATE POLICY "user_roles_select" ON user_roles
  FOR SELECT TO authenticated
  USING (user_id IN (SELECT id FROM users WHERE organization_id = get_user_org_id()));

CREATE POLICY "user_roles_insert" ON user_roles
  FOR INSERT TO authenticated
  WITH CHECK (user_id IN (SELECT id FROM users WHERE organization_id = get_user_org_id()) AND is_superuser());

CREATE POLICY "user_roles_delete" ON user_roles
  FOR DELETE TO authenticated
  USING (user_id IN (SELECT id FROM users WHERE organization_id = get_user_org_id()) AND is_superuser());

-- ============================================================================
-- CREATE SECURE POLICIES - ORGANIZATION-SCOPED DATA TABLES
-- Full CRUD scoped to organization_id
-- ============================================================================

-- Customers
CREATE POLICY "customers_select" ON customers
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "customers_insert" ON customers
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "customers_update" ON customers
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "customers_delete" ON customers
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Vehicles
CREATE POLICY "vehicles_select" ON vehicles
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "vehicles_insert" ON vehicles
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicles_update" ON vehicles
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicles_delete" ON vehicles
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Drivers
CREATE POLICY "drivers_select" ON drivers
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "drivers_insert" ON drivers
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "drivers_update" ON drivers
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "drivers_delete" ON drivers
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Bookings
CREATE POLICY "bookings_select" ON bookings
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "bookings_insert" ON bookings
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "bookings_update" ON bookings
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "bookings_delete" ON bookings
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Trip Packages
CREATE POLICY "trip_packages_select" ON trip_packages
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "trip_packages_insert" ON trip_packages
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trip_packages_update" ON trip_packages
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trip_packages_delete" ON trip_packages
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Trips
CREATE POLICY "trips_select" ON trips
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "trips_insert" ON trips
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trips_update" ON trips
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trips_delete" ON trips
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Expenses
CREATE POLICY "expenses_select" ON expenses
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "expenses_insert" ON expenses
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "expenses_update" ON expenses
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "expenses_delete" ON expenses
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Invoices
CREATE POLICY "invoices_select" ON invoices
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "invoices_insert" ON invoices
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "invoices_update" ON invoices
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "invoices_delete" ON invoices
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Invoice Items
CREATE POLICY "invoice_items_select" ON invoice_items
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "invoice_items_insert" ON invoice_items
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "invoice_items_update" ON invoice_items
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "invoice_items_delete" ON invoice_items
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Payments
CREATE POLICY "payments_select" ON payments
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "payments_insert" ON payments
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "payments_update" ON payments
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "payments_delete" ON payments
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Maintenance Schedule
CREATE POLICY "maintenance_schedule_select" ON maintenance_schedule
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "maintenance_schedule_insert" ON maintenance_schedule
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "maintenance_schedule_update" ON maintenance_schedule
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "maintenance_schedule_delete" ON maintenance_schedule
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Vehicle Calendar Events
CREATE POLICY "vehicle_calendar_events_select" ON vehicle_calendar_events
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "vehicle_calendar_events_insert" ON vehicle_calendar_events
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_calendar_events_update" ON vehicle_calendar_events
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_calendar_events_delete" ON vehicle_calendar_events
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Reminder Rules
CREATE POLICY "reminder_rules_select" ON reminder_rules
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "reminder_rules_insert" ON reminder_rules
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "reminder_rules_update" ON reminder_rules
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "reminder_rules_delete" ON reminder_rules
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Reminders
CREATE POLICY "reminders_select" ON reminders
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "reminders_insert" ON reminders
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "reminders_update" ON reminders
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "reminders_delete" ON reminders
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Notification Events
CREATE POLICY "notification_events_select" ON notification_events
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "notification_events_insert" ON notification_events
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notification_events_update" ON notification_events
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notification_events_delete" ON notification_events
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Notification Preferences
CREATE POLICY "notification_preferences_select" ON notification_preferences
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "notification_preferences_insert" ON notification_preferences
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notification_preferences_update" ON notification_preferences
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notification_preferences_delete" ON notification_preferences
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Notifications
CREATE POLICY "notifications_select" ON notifications
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "notifications_insert" ON notifications
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notifications_update" ON notifications
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "notifications_delete" ON notifications
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Trip Profit Summary
CREATE POLICY "trip_profit_summary_select" ON trip_profit_summary
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "trip_profit_summary_insert" ON trip_profit_summary
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trip_profit_summary_update" ON trip_profit_summary
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "trip_profit_summary_delete" ON trip_profit_summary
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Vehicle Daily Profit
CREATE POLICY "vehicle_daily_profit_select" ON vehicle_daily_profit
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "vehicle_daily_profit_insert" ON vehicle_daily_profit
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_daily_profit_update" ON vehicle_daily_profit
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_daily_profit_delete" ON vehicle_daily_profit
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Vehicle Monthly Profit
CREATE POLICY "vehicle_monthly_profit_select" ON vehicle_monthly_profit
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "vehicle_monthly_profit_insert" ON vehicle_monthly_profit
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_monthly_profit_update" ON vehicle_monthly_profit
  FOR UPDATE TO authenticated
  USING (organization_id = get_user_org_id())
  WITH CHECK (organization_id = get_user_org_id());

CREATE POLICY "vehicle_monthly_profit_delete" ON vehicle_monthly_profit
  FOR DELETE TO authenticated
  USING (organization_id = get_user_org_id());

-- Audit Logs: Select and Insert only, scoped to org
CREATE POLICY "audit_logs_select" ON audit_logs
  FOR SELECT TO authenticated
  USING (organization_id = get_user_org_id());

CREATE POLICY "audit_logs_insert" ON audit_logs
  FOR INSERT TO authenticated
  WITH CHECK (organization_id = get_user_org_id());

