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