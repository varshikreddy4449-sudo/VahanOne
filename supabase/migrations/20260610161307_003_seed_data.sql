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