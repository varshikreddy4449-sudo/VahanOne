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