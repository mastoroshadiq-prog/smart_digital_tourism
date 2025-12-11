-- ============================================================
-- SMART DIGITAL TOURISM - SAMPLE DATA
-- Execute AFTER supabase_setup.sql
-- ============================================================

-- ==========================================
-- Sample Villages (Desa Wisata)
-- ==========================================

-- Desa Wisata Penglipuran, Bali
INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Desa Wisata Penglipuran',
    'penglipuran',
    'Desa Penglipuran adalah salah satu desa adat terbersih di dunia. Terletak di Kabupaten Bangli, Bali, desa ini terkenal dengan arsitektur tradisional Bali yang masih terjaga dan keramahan penduduknya.',
    'Bangli',
    'Bali',
    ST_SetSRID(ST_GeomFromText('POLYGON((115.356 -8.420, 115.360 -8.420, 115.360 -8.424, 115.356 -8.424, 115.356 -8.420))'), 4326),
    ST_SetSRID(ST_MakePoint(115.358, -8.422), 4326),
    'https://example.com/penglipuran.jpg'
);

-- Desa Wisata Wae Rebo, Flores
INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Desa Wisata Wae Rebo',
    'wae-rebo',
    'Wae Rebo adalah desa adat suku Manggarai yang terletak di ketinggian 1.200 meter di atas permukaan laut. Desa ini terkenal dengan rumah adat berbentuk kerucut yang disebut Mbaru Niang.',
    'Manggarai',
    'Nusa Tenggara Timur',
    ST_SetSRID(ST_GeomFromText('POLYGON((120.295 -8.770, 120.300 -8.770, 120.300 -8.775, 120.295 -8.775, 120.295 -8.770))'), 4326),
    ST_SetSRID(ST_MakePoint(120.2975, -8.7725), 4326),
    'https://example.com/waerebo.jpg'
);

-- Desa Wisata Nglanggeran, Yogyakarta
INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'Desa Wisata Nglanggeran',
    'nglanggeran',
    'Desa Nglanggeran terkenal dengan Gunung Api Purba yang berusia jutaan tahun. Menawarkan pemandangan sunrise yang spektakuler dan berbagai aktivitas ekowisata.',
    'Gunungkidul',
    'DI Yogyakarta',
    ST_SetSRID(ST_GeomFromText('POLYGON((110.505 -7.855, 110.515 -7.855, 110.515 -7.865, 110.505 -7.865, 110.505 -7.855))'), 4326),
    ST_SetSRID(ST_MakePoint(110.510, -7.860), 4326),
    'https://example.com/nglanggeran.jpg'
);

-- ==========================================
-- Sample Attractions (Objek Wisata)
-- ==========================================

-- Attractions di Penglipuran
INSERT INTO attractions (village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES 
(
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Jalan Utama Penglipuran',
    'Jalan utama desa yang ikonik dengan deretan rumah tradisional Bali yang seragam dan asri.',
    'culture',
    50000,
    ST_SetSRID(ST_MakePoint(115.358, -8.422), 4326),
    'https://example.com/jalan-penglipuran.jpg',
    4.8
),
(
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Hutan Bambu Penglipuran',
    'Hutan bambu yang rindang dan sejuk, cocok untuk berjalan santai dan fotografi.',
    'nature',
    25000,
    ST_SetSRID(ST_MakePoint(115.359, -8.423), 4326),
    'https://example.com/hutan-bambu.jpg',
    4.5
),
(
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Warung Kopi Tradisional',
    'Warung kopi dengan suasana tradisional yang menyajikan kopi Bali dan jajanan lokal.',
    'culinary',
    0,
    ST_SetSRID(ST_MakePoint(115.357, -8.421), 4326),
    'https://example.com/warung-kopi.jpg',
    4.3
);

-- Attractions di Wae Rebo
INSERT INTO attractions (village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES 
(
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Mbaru Niang',
    'Rumah adat berbentuk kerucut yang menjadi ikon Wae Rebo. Diakui UNESCO sebagai warisan budaya.',
    'culture',
    350000,
    ST_SetSRID(ST_MakePoint(120.2975, -8.7725), 4326),
    'https://example.com/mbaru-niang.jpg',
    4.9
),
(
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'Sunrise Point Wae Rebo',
    'Titik terbaik untuk menikmati matahari terbit di atas hamparan kabut lembah.',
    'nature',
    0,
    ST_SetSRID(ST_MakePoint(120.298, -8.771), 4326),
    'https://example.com/sunrise-waerebo.jpg',
    4.8
);

-- Attractions di Nglanggeran
INSERT INTO attractions (village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES 
(
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'Gunung Api Purba',
    'Situs geologi berupa gunung api yang sudah tidak aktif selama jutaan tahun. Cocok untuk hiking.',
    'nature',
    15000,
    ST_SetSRID(ST_MakePoint(110.510, -7.858), 4326),
    'https://example.com/gunung-api-purba.jpg',
    4.7
),
(
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'Embung Nglanggeran',
    'Waduk buatan dengan pemandangan indah, populer untuk piknik dan bersantai.',
    'artificial',
    5000,
    ST_SetSRID(ST_MakePoint(110.508, -7.862), 4326),
    'https://example.com/embung.jpg',
    4.4
),
(
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'Kuliner Cokelat Nglanggeran',
    'Tempat produksi dan penjualan cokelat lokal dari kakao yang ditanam di desa.',
    'culinary',
    0,
    ST_SetSRID(ST_MakePoint(110.512, -7.860), 4326),
    'https://example.com/cokelat.jpg',
    4.2
);

-- ==========================================
-- Sample Homestays
-- ==========================================

INSERT INTO homestays (village_id, name, description, address, location_point, contact_number, is_active)
VALUES 
(
    'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
    'Homestay Bali Traditional',
    'Penginapan dengan arsitektur tradisional Bali, dilengkapi dengan sarapan pagi.',
    'Jl. Desa Penglipuran No. 10',
    ST_SetSRID(ST_MakePoint(115.357, -8.421), 4326),
    '081234567890',
    true
),
(
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'Omah Joglo Nglanggeran',
    'Rumah Joglo yang dikonversi menjadi homestay dengan pemandangan gunung.',
    'Dusun Nglanggeran, Patuk',
    ST_SetSRID(ST_MakePoint(110.509, -7.861), 4326),
    '085678901234',
    true
);

-- ==========================================
-- Sample Rooms
-- ==========================================

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT 
    h.id,
    'Kamar Deluxe',
    350000,
    2,
    ARRAY['WiFi', 'AC', 'Breakfast', 'Hot Water'],
    3
FROM homestays h WHERE h.name = 'Homestay Bali Traditional';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT 
    h.id,
    'Kamar Standard',
    200000,
    2,
    ARRAY['Fan', 'Breakfast'],
    5
FROM homestays h WHERE h.name = 'Homestay Bali Traditional';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT 
    h.id,
    'Kamar Joglo',
    450000,
    4,
    ARRAY['Traditional Design', 'Breakfast', 'Mountain View'],
    2
FROM homestays h WHERE h.name = 'Omah Joglo Nglanggeran';

-- ==========================================
-- Verify Data
-- ==========================================

-- Check villages
SELECT name, district, province FROM villages;

-- Check attractions count per village
SELECT v.name, COUNT(a.id) as attraction_count
FROM villages v
LEFT JOIN attractions a ON a.village_id = v.id
GROUP BY v.id, v.name;

-- Test geofencing function (should return Penglipuran)
SELECT name FROM check_geofence(-8.422, 115.358);

-- Test nearby attractions (5km from Penglipuran center)
SELECT name, category, distance_meters 
FROM get_nearby_attractions(-8.422, 115.358, 5000);

-- ============================================================
-- SAMPLE DATA LOADED SUCCESSFULLY!
-- ============================================================
