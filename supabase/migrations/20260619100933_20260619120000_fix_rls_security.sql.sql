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