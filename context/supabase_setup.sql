-- ============================================================
-- SMART DIGITAL TOURISM - DATABASE SETUP
-- Execute this SQL in Supabase SQL Editor
-- ============================================================

-- ==========================================
-- STEP 1: Enable Required Extensions
-- ==========================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ==========================================
-- STEP 2: Create ENUM Types
-- ==========================================
DO $$ 
BEGIN
    -- User Role Enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role_enum') THEN
        CREATE TYPE user_role_enum AS ENUM ('tourist', 'village_admin', 'homestay_owner', 'super_admin');
    END IF;
    
    -- Attraction Category Enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'attraction_category_enum') THEN
        CREATE TYPE attraction_category_enum AS ENUM ('nature', 'culture', 'artificial', 'culinary');
    END IF;
    
    -- Transaction Status Enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trx_status_enum') THEN
        CREATE TYPE trx_status_enum AS ENUM ('pending', 'paid', 'expired', 'cancelled', 'completed');
    END IF;
    
    -- Item Type Enum
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'item_type_enum') THEN
        CREATE TYPE item_type_enum AS ENUM ('ticket', 'homestay', 'packet');
    END IF;
END $$;

-- ==========================================
-- STEP 3: Create Tables
-- ==========================================

-- 3.1 Users Table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    phone_number VARCHAR(20),
    role user_role_enum DEFAULT 'tourist',
    fcm_token TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3.2 Villages Table (Spatial Core)
CREATE TABLE IF NOT EXISTS villages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    district VARCHAR(100),
    province VARCHAR(100),
    area_polygon GEOMETRY(POLYGON, 4326) NOT NULL,
    center_point GEOMETRY(POINT, 4326),
    thumbnail_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial Index for Villages (IMPORTANT for geofencing performance)
CREATE INDEX IF NOT EXISTS idx_villages_area ON villages USING GIST (area_polygon);
CREATE INDEX IF NOT EXISTS idx_villages_center ON villages USING GIST (center_point);

-- 3.3 Attractions Table
CREATE TABLE IF NOT EXISTS attractions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    village_id UUID NOT NULL REFERENCES villages(id) ON DELETE CASCADE,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    category attraction_category_enum NOT NULL,
    price DECIMAL(10, 2) DEFAULT 0,
    location_point GEOMETRY(POINT, 4326) NOT NULL,
    thumbnail_url TEXT,
    gallery_urls TEXT[],
    rating DECIMAL(2, 1) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Spatial Index for Attractions
CREATE INDEX IF NOT EXISTS idx_attractions_location ON attractions USING GIST (location_point);
CREATE INDEX IF NOT EXISTS idx_attractions_village ON attractions(village_id);

-- 3.4 Homestays Table
CREATE TABLE IF NOT EXISTS homestays (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    village_id UUID NOT NULL REFERENCES villages(id) ON DELETE CASCADE,
    owner_id UUID REFERENCES users(id),
    name VARCHAR(150) NOT NULL,
    description TEXT,
    address TEXT,
    location_point GEOMETRY(POINT, 4326),
    contact_number VARCHAR(20),
    thumbnail_url TEXT,
    gallery_urls TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_homestays_village ON homestays(village_id);
CREATE INDEX IF NOT EXISTS idx_homestays_location ON homestays USING GIST (location_point);

-- 3.5 Rooms Table
CREATE TABLE IF NOT EXISTS rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    homestay_id UUID NOT NULL REFERENCES homestays(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    capacity INT DEFAULT 2,
    amenities TEXT[],
    thumbnail_url TEXT,
    gallery_urls TEXT[],
    stock INT DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_rooms_homestay ON rooms(homestay_id);

-- 3.6 Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL,
    status trx_status_enum DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_url TEXT,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);

-- 3.7 Transaction Items Table
CREATE TABLE IF NOT EXISTS transaction_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    item_type item_type_enum NOT NULL,
    reference_id UUID NOT NULL,
    quantity INT DEFAULT 1,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    visit_date DATE NOT NULL,
    ticket_code VARCHAR(20) UNIQUE,
    is_redeemed BOOLEAN DEFAULT FALSE,
    redeemed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_transaction_items_transaction ON transaction_items(transaction_id);
CREATE INDEX IF NOT EXISTS idx_transaction_items_ticket ON transaction_items(ticket_code);

-- ==========================================
-- STEP 4: Create RPC Functions for Geofencing
-- ==========================================

-- 4.1 Check Geofence - Detect if user is inside a village
CREATE OR REPLACE FUNCTION check_geofence(user_lat DOUBLE PRECISION, user_lon DOUBLE PRECISION)
RETURNS SETOF villages
LANGUAGE sql
STABLE
AS $$
    SELECT * 
    FROM villages 
    WHERE ST_Contains(
        area_polygon, 
        ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)
    );
$$;

-- 4.2 Get Nearby Attractions - Find attractions within radius
CREATE OR REPLACE FUNCTION get_nearby_attractions(
    user_lat DOUBLE PRECISION, 
    user_lon DOUBLE PRECISION, 
    radius_meters DOUBLE PRECISION DEFAULT 5000
)
RETURNS TABLE (
    id UUID,
    village_id UUID,
    name VARCHAR(150),
    description TEXT,
    category attraction_category_enum,
    price DECIMAL(10, 2),
    location_point GEOMETRY(POINT, 4326),
    thumbnail_url TEXT,
    gallery_urls TEXT[],
    rating DECIMAL(2, 1),
    created_at TIMESTAMP WITH TIME ZONE,
    distance_meters DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        a.id,
        a.village_id,
        a.name,
        a.description,
        a.category,
        a.price,
        a.location_point,
        a.thumbnail_url,
        a.gallery_urls,
        a.rating,
        a.created_at,
        ST_Distance(
            a.location_point::geography,
            ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography
        ) as distance_meters
    FROM attractions a
    WHERE ST_DWithin(
        a.location_point::geography,
        ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography,
        radius_meters
    )
    ORDER BY distance_meters ASC;
$$;

-- 4.3 Get Nearby Homestays
CREATE OR REPLACE FUNCTION get_nearby_homestays(
    user_lat DOUBLE PRECISION, 
    user_lon DOUBLE PRECISION, 
    radius_meters DOUBLE PRECISION DEFAULT 5000
)
RETURNS TABLE (
    id UUID,
    village_id UUID,
    name VARCHAR(150),
    description TEXT,
    address TEXT,
    location_point GEOMETRY(POINT, 4326),
    contact_number VARCHAR(20),
    thumbnail_url TEXT,
    is_active BOOLEAN,
    distance_meters DOUBLE PRECISION
)
LANGUAGE sql
STABLE
AS $$
    SELECT 
        h.id,
        h.village_id,
        h.name,
        h.description,
        h.address,
        h.location_point,
        h.contact_number,
        h.thumbnail_url,
        h.is_active,
        ST_Distance(
            h.location_point::geography,
            ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography
        ) as distance_meters
    FROM homestays h
    WHERE h.is_active = true
    AND ST_DWithin(
        h.location_point::geography,
        ST_SetSRID(ST_MakePoint(user_lon, user_lat), 4326)::geography,
        radius_meters
    )
    ORDER BY distance_meters ASC;
$$;

-- ==========================================
-- STEP 5: Row Level Security (RLS)
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE villages ENABLE ROW LEVEL SECURITY;
ALTER TABLE attractions ENABLE ROW LEVEL SECURITY;
ALTER TABLE homestays ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Villages policies (public read)
CREATE POLICY "Anyone can view villages" ON villages
    FOR SELECT USING (true);

-- Attractions policies (public read)
CREATE POLICY "Anyone can view attractions" ON attractions
    FOR SELECT USING (true);

-- Homestays policies (public read for active)
CREATE POLICY "Anyone can view active homestays" ON homestays
    FOR SELECT USING (is_active = true);

CREATE POLICY "Owners can manage their homestays" ON homestays
    FOR ALL USING (auth.uid() = owner_id);

-- Rooms policies (public read)
CREATE POLICY "Anyone can view rooms" ON rooms
    FOR SELECT USING (true);

-- Transactions policies
CREATE POLICY "Users can view their own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Transaction items policies
CREATE POLICY "Users can view their own transaction items" ON transaction_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM transactions t 
            WHERE t.id = transaction_items.transaction_id 
            AND t.user_id = auth.uid()
        )
    );

-- ==========================================
-- STEP 6: Triggers for Updated At
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ==========================================
-- STEP 7: Create User Profile on Auth Signup
-- ==========================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, role)
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        'tourist'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

-- ==========================================
-- DONE! Database setup complete.
-- ==========================================
