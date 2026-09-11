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