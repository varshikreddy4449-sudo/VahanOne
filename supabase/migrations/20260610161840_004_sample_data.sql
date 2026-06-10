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