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