-- TransitOps Database Schema
-- Relationship Summary:
-- roles (1) <--- (N) users
-- vehicles (1) <--- (N) trips
-- drivers (1) <--- (N) trips
-- vehicles (1) <--- (N) maintenance_logs
-- vehicles (1) <--- (N) fuel_logs
-- vehicles (1) <--- (N) expenses
-- trips (1) <--- (0..1) fuel_logs
-- maintenance_logs (1) <--- (0..1) expenses

-- 1. Roles Table
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Users Table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL REFERENCES roles(id) ON DELETE RESTRICT, -- Restrict role deletion if users are assigned to it
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Vehicles Table
CREATE TABLE vehicles (
    id SERIAL PRIMARY KEY,
    registration_number VARCHAR(100) UNIQUE NOT NULL,
    name_model VARCHAR(255) NOT NULL,
    type VARCHAR(100) NOT NULL,
    max_load_capacity NUMERIC NOT NULL,
    odometer NUMERIC DEFAULT 0,
    acquisition_cost NUMERIC NOT NULL,
    status VARCHAR(50) DEFAULT 'Available' CHECK (status IN ('Available', 'On Trip', 'In Shop', 'Retired')),
    region VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Drivers Table
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    license_category VARCHAR(100) NOT NULL,
    license_expiry_date DATE NOT NULL,
    contact_number VARCHAR(100) NOT NULL,
    safety_score NUMERIC DEFAULT 100 CHECK (safety_score >= 0 AND safety_score <= 100),
    status VARCHAR(50) DEFAULT 'Available' CHECK (status IN ('Available', 'On Trip', 'Off Duty', 'Suspended')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Trips Table
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    source VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT, -- Restrict deleting vehicles with trip history for accountability
    driver_id INTEGER NOT NULL REFERENCES drivers(id) ON DELETE RESTRICT,   -- Restrict deleting drivers with trip history for accountability
    cargo_weight NUMERIC NOT NULL,
    planned_distance NUMERIC NOT NULL,
    status VARCHAR(50) DEFAULT 'Draft' CHECK (status IN ('Draft', 'Dispatched', 'Completed', 'Cancelled')),
    actual_odometer NUMERIC,
    fuel_consumed NUMERIC,
    revenue NUMERIC DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    dispatched_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP
);

-- 6. Maintenance Logs Table
CREATE TABLE maintenance_logs (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT, -- Restrict deleting vehicles with active/historical maintenance entries
    service_type VARCHAR(255) NOT NULL,
    cost NUMERIC NOT NULL,
    date DATE NOT NULL,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'Active' CHECK (status IN ('Active', 'Closed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Fuel Logs Table
CREATE TABLE fuel_logs (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE, -- Cascade delete fuel logs if a vehicle is deleted, as they are dependent history
    liters NUMERIC NOT NULL,
    cost NUMERIC NOT NULL,
    date DATE NOT NULL,
    trip_id INTEGER REFERENCES trips(id) ON DELETE SET NULL -- Set trip_id to NULL if a trip is deleted, keeping the fuel expense history
);

-- 8. Expenses Table
CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE, -- Cascade delete expenses if a vehicle is deleted, as they are dependent history
    type VARCHAR(50) NOT NULL CHECK (type IN ('Toll', 'Maintenance', 'Other')),
    amount NUMERIC NOT NULL,
    date DATE NOT NULL,
    maintenance_log_id INTEGER REFERENCES maintenance_logs(id) ON DELETE SET NULL -- Set maintenance_log_id to NULL if log is deleted, keeping the expense history
);

-- Indexes for performance optimization on heavily filtered/searched columns
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_vehicles_registration_number ON vehicles(registration_number);
CREATE INDEX idx_drivers_status ON drivers(status);
CREATE INDEX idx_drivers_license_expiry_date ON drivers(license_expiry_date);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_trips_vehicle_id ON trips(vehicle_id);
CREATE INDEX idx_trips_driver_id ON trips(driver_id);
