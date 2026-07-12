-- TransitOps Seed Data

-- 1. Insert Roles
INSERT INTO roles (id, name) VALUES
(1, 'Fleet Manager'),
(2, 'Dispatcher'),
(3, 'Safety Officer'),
(4, 'Financial Analyst')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- 2. Insert Users
-- Password for all accounts: password123
-- Hash: $2a$10$1Vx8WyV1Q2tPdNUa.RM8keYRcDeKIWej.AV4THUg8r7Ko0kPm/0dy
INSERT INTO users (name, email, password_hash, role_id) VALUES
('John Fleet Manager', 'manager@transitops.com', '$2a$10$1Vx8WyV1Q2tPdNUa.RM8keYRcDeKIWej.AV4THUg8r7Ko0kPm/0dy', 1),
('Alice Dispatcher', 'dispatcher@transitops.com', '$2a$10$1Vx8WyV1Q2tPdNUa.RM8keYRcDeKIWej.AV4THUg8r7Ko0kPm/0dy', 2),
('Bob Safety Officer', 'safety@transitops.com', '$2a$10$1Vx8WyV1Q2tPdNUa.RM8keYRcDeKIWej.AV4THUg8r7Ko0kPm/0dy', 3),
('Charlie Financial Analyst', 'finance@transitops.com', '$2a$10$1Vx8WyV1Q2tPdNUa.RM8keYRcDeKIWej.AV4THUg8r7Ko0kPm/0dy', 4)
ON CONFLICT (email) DO UPDATE SET password_hash = EXCLUDED.password_hash;

-- 3. Insert Vehicles
INSERT INTO vehicles (id, registration_number, name_model, type, max_load_capacity, odometer, acquisition_cost, status, region) VALUES
(1, 'TX-TRUCK-01', 'Freightliner Cascadia', 'Heavy Duty Truck', 15000, 45200, 125000, 'Available', 'North'),
(2, 'TX-VAN-02', 'Ford Transit 350', 'Delivery Van', 3500, 12500, 48000, 'On Trip', 'West'),
(3, 'TX-BOX-03', 'Isuzu NPR-HD', 'Box Truck', 7000, 85600, 65000, 'In Shop', 'East'),
(4, 'TX-FLAT-04', 'Kenworth T880', 'Flatbed', 20000, 310000, 145000, 'Retired', 'South'),
(5, 'TX-VAN-05', 'Mercedes-Benz Sprinter', 'Delivery Van', 4000, 2500, 52000, 'Available', 'North')
ON CONFLICT (id) DO UPDATE SET 
    registration_number = EXCLUDED.registration_number,
    name_model = EXCLUDED.name_model,
    type = EXCLUDED.type,
    max_load_capacity = EXCLUDED.max_load_capacity,
    odometer = EXCLUDED.odometer,
    acquisition_cost = EXCLUDED.acquisition_cost,
    status = EXCLUDED.status,
    region = EXCLUDED.region;

-- 4. Insert Drivers
-- License expiry date calculations:
-- Driver 3 is expired (past date)
-- Driver 5 is expiring soon (within 30 days, e.g., current date + 15 days)
-- Driver 1 and 2 are active (far future)
INSERT INTO drivers (id, name, license_number, license_category, license_expiry_date, contact_number, safety_score, status) VALUES
(1, 'David Miller', 'DL-8849302', 'Class A CDL', '2028-10-15', '+1-555-0192', 96, 'Available'),
(2, 'Sarah Jenkins', 'DL-7738291', 'Class A CDL', '2027-04-20', '+1-555-0143', 92, 'On Trip'),
(3, 'James Smith', 'DL-1122334', 'Class B CDL', '2026-06-30', '+1-555-0188', 78, 'Off Duty'), -- Expired license (relative to July 2026)
(4, 'Robert Johnson', 'DL-9988776', 'Class A CDL', '2029-01-12', '+1-555-0177', 45, 'Suspended'), -- Suspended driver
(5, 'Emily Davis', 'DL-4455667', 'Class B CDL', '2026-07-27', '+1-555-0155', 89, 'Available') -- License expiring in 15 days
ON CONFLICT (id) DO UPDATE SET 
    name = EXCLUDED.name,
    license_number = EXCLUDED.license_number,
    license_category = EXCLUDED.license_category,
    license_expiry_date = EXCLUDED.license_expiry_date,
    contact_number = EXCLUDED.contact_number,
    safety_score = EXCLUDED.safety_score,
    status = EXCLUDED.status;

-- Reset PK serial sequences (for postgres)
SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));
SELECT setval('vehicles_id_seq', (SELECT MAX(id) FROM vehicles));
SELECT setval('drivers_id_seq', (SELECT MAX(id) FROM drivers));

-- 5. Insert Trips
INSERT INTO trips (id, source, destination, vehicle_id, driver_id, cargo_weight, planned_distance, status, actual_odometer, fuel_consumed, revenue, created_at, dispatched_at, completed_at) VALUES
(1, 'Dallas, TX', 'Houston, TX', 1, 1, 12000, 240, 'Draft', NULL, NULL, 0, CURRENT_TIMESTAMP, NULL, NULL),
(2, 'Austin, TX', 'San Antonio, TX', 2, 2, 2800, 80, 'Dispatched', NULL, NULL, 0, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL),
(3, 'Fort Worth, TX', 'El Paso, TX', 5, 5, 3100, 600, 'Completed', 8500, 180, 2400, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '2 days')
ON CONFLICT (id) DO UPDATE SET 
    source = EXCLUDED.source,
    destination = EXCLUDED.destination,
    vehicle_id = EXCLUDED.vehicle_id,
    driver_id = EXCLUDED.driver_id,
    cargo_weight = EXCLUDED.cargo_weight,
    planned_distance = EXCLUDED.planned_distance,
    status = EXCLUDED.status,
    actual_odometer = EXCLUDED.actual_odometer,
    fuel_consumed = EXCLUDED.fuel_consumed,
    revenue = EXCLUDED.revenue;

SELECT setval('trips_id_seq', (SELECT MAX(id) FROM trips));

-- 6. Insert Maintenance Logs
INSERT INTO maintenance_logs (id, vehicle_id, service_type, cost, date, notes, status) VALUES
(1, 3, 'Engine Overhaul & Brake Replacement', 1850.00, '2026-07-10', 'Replacing front brake pads, rotors, and spark plugs.', 'Active'),
(2, 1, 'Routine Oil Change & Tire Rotation', 150.00, '2026-07-01', 'Standard 10,000 mile maintenance log.', 'Closed')
ON CONFLICT (id) DO UPDATE SET 
    vehicle_id = EXCLUDED.vehicle_id,
    service_type = EXCLUDED.service_type,
    cost = EXCLUDED.cost,
    date = EXCLUDED.date,
    notes = EXCLUDED.notes,
    status = EXCLUDED.status;

SELECT setval('maintenance_logs_id_seq', (SELECT MAX(id) FROM maintenance_logs));

-- 7. Insert Fuel Logs
INSERT INTO fuel_logs (id, vehicle_id, liters, cost, date, trip_id) VALUES
(1, 1, 120.00, 180.00, '2026-07-02', NULL),
(2, 2, 45.00, 67.50, '2026-07-05', 2),
(3, 5, 180.00, 270.00, '2026-07-10', 3)
ON CONFLICT (id) DO UPDATE SET 
    vehicle_id = EXCLUDED.vehicle_id,
    liters = EXCLUDED.liters,
    cost = EXCLUDED.cost,
    date = EXCLUDED.date,
    trip_id = EXCLUDED.trip_id;

SELECT setval('fuel_logs_id_seq', (SELECT MAX(id) FROM fuel_logs));

-- 8. Insert Expenses
INSERT INTO expenses (id, vehicle_id, type, amount, date, maintenance_log_id) VALUES
(1, 1, 'Toll', 45.00, '2026-07-02', NULL),
(2, 1, 'Maintenance', 150.00, '2026-07-01', 2),
(3, 2, 'Other', 25.00, '2026-07-05', NULL)
ON CONFLICT (id) DO UPDATE SET 
    vehicle_id = EXCLUDED.vehicle_id,
    type = EXCLUDED.type,
    amount = EXCLUDED.amount,
    date = EXCLUDED.date,
    maintenance_log_id = EXCLUDED.maintenance_log_id;

SELECT setval('expenses_id_seq', (SELECT MAX(id) FROM expenses));
