-- ============================================================
-- SMART DIGITAL TOURISM - DATA WISATA GUNUNGPATI SEMARANG
-- Execute AFTER supabase_setup.sql
-- ============================================================

-- ==========================================
-- Data Desa Wisata Gunungpati
-- Koordinat approximate untuk area Gunungpati
-- ==========================================

-- Hapus data sample lama jika ada (opsional)
-- DELETE FROM transaction_items;
-- DELETE FROM transactions;
-- DELETE FROM rooms;
-- DELETE FROM homestays;
-- DELETE FROM attractions;
-- DELETE FROM villages;

-- ==========================================
-- Insert Desa Wisata Kandri (Gunungpati)
-- ==========================================

INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Desa Wisata Kandri',
    'desa-wisata-kandri',
    'Desa Wisata Kandri adalah desa wisata unggulan di Kecamatan Gunungpati, Semarang. Terkenal dengan kegiatan river tubing sepanjang 4 km, keindahan alam pedesaan, dan keramahan penduduk lokalnya. Desa ini menawarkan pengalaman hidup tradisional dengan pemandangan hijau yang asri.',
    'Gunungpati',
    'Jawa Tengah',
    ST_SetSRID(ST_GeomFromText('POLYGON((110.345 -7.055, 110.365 -7.055, 110.365 -7.075, 110.345 -7.075, 110.345 -7.055))'), 4326),
    ST_SetSRID(ST_MakePoint(110.355, -7.065), 4326),
    'https://example.com/kandri.jpg'
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- Insert Desa Wisata Jatirejo
-- ==========================================

INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'd2e3f4a5-b6c7-8901-bcde-gunungpati002',
    'Desa Wisata Jatirejo',
    'desa-wisata-jatirejo',
    'Desa Wisata Jatirejo dikenal sebagai penghasil kolang-kaling terbesar di Semarang. Pengunjung dapat melihat aktivitas berkebun, memetik tanaman, mengolah kolang-kaling, menggembala kerbau, dan membuat keripik. Tersedia paket trail adventure dan river tubing.',
    'Gunungpati',
    'Jawa Tengah',
    ST_SetSRID(ST_GeomFromText('POLYGON((110.330 -7.040, 110.350 -7.040, 110.350 -7.060, 110.330 -7.060, 110.330 -7.040))'), 4326),
    ST_SetSRID(ST_MakePoint(110.340, -7.050), 4326),
    'https://example.com/jatirejo.jpg'
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- Insert Kampung Jawi
-- ==========================================

INSERT INTO villages (id, name, slug, description, district, province, area_polygon, center_point, thumbnail_url)
VALUES (
    'd3e4f5a6-b7c8-9012-cdef-gunungpati003',
    'Thematic Kampung Jawi',
    'kampung-jawi',
    'Kampung Jawi menyajikan nuansa Jawa tempo dulu yang kental. Pengunjung dapat bernostalgia dengan suasana pedesaan tradisional dan mencicipi kuliner khas Jawa yang otentik. Cocok untuk mengenalkan budaya Jawa kepada generasi muda.',
    'Gunungpati',
    'Jawa Tengah',
    ST_SetSRID(ST_GeomFromText('POLYGON((110.360 -7.045, 110.375 -7.045, 110.375 -7.060, 110.360 -7.060, 110.360 -7.045))'), 4326),
    ST_SetSRID(ST_MakePoint(110.3675, -7.0525), 4326),
    'https://example.com/kampung-jawi.jpg'
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- OBJEK WISATA - Wisata Alam
-- ==========================================

-- Gua Kreo
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-001',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Gua Kreo',
    'Wisata alam yang menyajikan pemandangan indah dan sejuk. Terkenal dengan legenda kera penunggu dan koloni kera ekor panjang yang jinak. Pengunjung dapat menelusuri gua, berfoto di jembatan gantung, menikmati air terjun kecil, dan berinteraksi dengan monyet.',
    'nature',
    10000,
    ST_SetSRID(ST_MakePoint(110.3545, -7.0640), 4326),
    'https://example.com/gua-kreo.jpg',
    4.5
) ON CONFLICT (id) DO NOTHING;

-- Waduk Jatibarang
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-002',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Waduk Jatibarang',
    'Waduk multifungsi yang berfungsi sebagai pengendali banjir sekaligus destinasi wisata keluarga favorit. Pengunjung dapat menjelajahi waduk dengan perahu cepat (speedboat), menikmati panorama perbukitan hijau, dan bersantai di tepian waduk.',
    'artificial',
    15000,
    ST_SetSRID(ST_MakePoint(110.3520, -7.0580), 4326),
    'https://example.com/waduk-jatibarang.jpg',
    4.6
) ON CONFLICT (id) DO NOTHING;

-- Curug Lawe Benowo
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-003',
    'd2e3f4a5-b6c7-8901-bcde-gunungpati002',
    'Curug Lawe Benowo',
    'Air terjun tersembunyi yang menawan dengan air jernih dan segar. Dikelilingi pepohonan rindang dan suasana alami. Untuk mencapainya, pengunjung harus melakukan trekking melalui hutan lebat yang menantang namun sepadan.',
    'nature',
    5000,
    ST_SetSRID(ST_MakePoint(110.3380, -7.0480), 4326),
    'https://example.com/curug-lawe.jpg',
    4.4
) ON CONFLICT (id) DO NOTHING;

-- River Tubing Kandri
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-004',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'River Tubing Kandri',
    'Pengalaman river tubing seru sepanjang 4 km dengan waktu tempuh sekitar 3 jam menyusuri sungai di Desa Kandri. Menikmati keindahan alam pedesaan sambil bermain air. Cocok untuk keluarga dan rombongan.',
    'nature',
    75000,
    ST_SetSRID(ST_MakePoint(110.3560, -7.0670), 4326),
    'https://example.com/river-tubing.jpg',
    4.7
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- OBJEK WISATA - Taman Rekreasi
-- ==========================================

-- D'Pongs Wisata Keluarga
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-005',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'D''Pongs Wisata Keluarga',
    'Taman rekreasi keluarga lengkap dengan berbagai aktivitas: berenang, panahan, ATV, interaksi dengan satwa, outbound, paintball, horse riding, high rope, dan mini trail. Tersedia area hammock untuk bersantai dan spot foto menarik.',
    'artificial',
    35000,
    ST_SetSRID(ST_MakePoint(110.3610, -7.0590), 4326),
    'https://example.com/dpongs.jpg',
    4.5
) ON CONFLICT (id) DO NOTHING;

-- Ngrembel Asri
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-006',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Wisata Ngrembel Asri',
    'Destinasi wisata keluarga dengan wahana outbound, ATV, Omah Kayu yang unik, kolam pasir untuk anak, serta kolam renang dengan patung dinosaurus dan ember tumpah. Terdapat restoran dengan menu lokal yang lezat.',
    'artificial',
    25000,
    ST_SetSRID(ST_MakePoint(110.3650, -7.0620), 4326),
    'https://example.com/ngrembel-asri.jpg',
    4.4
) ON CONFLICT (id) DO NOTHING;

-- Green Fresh Farm
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-007',
    'd2e3f4a5-b6c7-8901-bcde-gunungpati002',
    'Green Fresh Farm',
    'Agrowisata dengan konsep farm to table. Pengunjung dapat belajar tentang pertanian organik, memetik sayuran segar, dan menikmati kuliner dari hasil kebun sendiri. Cocok untuk edukasi anak-anak.',
    'artificial',
    20000,
    ST_SetSRID(ST_MakePoint(110.3420, -7.0520), 4326),
    'https://example.com/green-fresh-farm.jpg',
    4.3
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- OBJEK WISATA - Budaya
-- ==========================================

-- Sentra Batik Warna Alam
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-008',
    'd3e4f5a6-b7c8-9012-cdef-gunungpati003',
    'Sentra Batik Warna Alam Gunungpati',
    'Pusat aktivitas ekonomi kreatif masyarakat Gunungpati di Kampung Malon. Pengunjung dapat melihat proses pembuatan batik dengan pewarna alami, belajar membatik, dan membeli batik khas Gunungpati sebagai oleh-oleh.',
    'culture',
    15000,
    ST_SetSRID(ST_MakePoint(110.3680, -7.0540), 4326),
    'https://example.com/batik-gunungpati.jpg',
    4.2
) ON CONFLICT (id) DO NOTHING;

-- Kampung Jawi Experience
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-009',
    'd3e4f5a6-b7c8-9012-cdef-gunungpati003',
    'Pengalaman Kampung Jawi',
    'Wisata budaya dengan nuansa Jawa tempo dulu. Pengunjung dapat berpakaian tradisional Jawa, belajar tari tradisional, membuat jamu, dan menikmati pertunjukan gamelan. Nostalgia budaya Jawa yang autentik.',
    'culture',
    30000,
    ST_SetSRID(ST_MakePoint(110.3670, -7.0530), 4326),
    'https://example.com/kampung-jawi-experience.jpg',
    4.6
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- OBJEK WISATA - Kuliner
-- ==========================================

-- Wisata Kuliner Dewandaru
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-010',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Wisata Dewandaru - Pemancingan & Kuliner',
    'Tempat wisata keluarga yang menggabungkan pemancingan dan kuliner. Pengunjung dapat memancing ikan segar kemudian memasaknya di tempat. Menu andalan: ikan bakar, pecel lele, dan aneka seafood segar.',
    'culinary',
    0,
    ST_SetSRID(ST_MakePoint(110.3580, -7.0600), 4326),
    'https://example.com/dewandaru.jpg',
    4.3
) ON CONFLICT (id) DO NOTHING;

-- Kuliner Tradisional Kampung Jawi
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-011',
    'd3e4f5a6-b7c8-9012-cdef-gunungpati003',
    'Kuliner Tradisional Kampung Jawi',
    'Nikmati aneka kuliner khas Jawa tempo dulu: nasi liwet, jenang, wedang uwuh, tahu gimbal, lumpia mini, dan jajanan pasar tradisional. Semua disajikan dengan cara tradisional menggunakan peralatan tanah liat dan daun pisang.',
    'culinary',
    0,
    ST_SetSRID(ST_MakePoint(110.3665, -7.0520), 4326),
    'https://example.com/kuliner-jawi.jpg',
    4.5
) ON CONFLICT (id) DO NOTHING;

-- Kebun Durian Monti
INSERT INTO attractions (id, village_id, name, description, category, price, location_point, thumbnail_url, rating)
VALUES (
    'att-gunungpati-012',
    'd2e3f4a5-b6c7-8901-bcde-gunungpati002',
    'Kebun Durian Monti',
    'Kebun durian dengan konsep petik langsung dari pohon. Panen setahun sekali (musim durian sekitar Desember-Februari). Wisatawan dapat menikmati durian segar langsung di kebun dengan pemandangan hijau.',
    'culinary',
    50000,
    ST_SetSRID(ST_MakePoint(110.3350, -7.0450), 4326),
    'https://example.com/kebun-durian.jpg',
    4.7
) ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- HOMESTAY
-- ==========================================

INSERT INTO homestays (id, village_id, name, description, address, location_point, contact_number, is_active)
VALUES 
(
    'hms-gunungpati-001',
    'd1e2f3a4-b5c6-7890-abcd-gunungpati001',
    'Homestay Kandri Village',
    'Homestay dengan suasana pedesaan asli. Pengalaman menginap di rumah penduduk lokal dengan sarapan masakan rumahan. Cocok untuk merasakan kehidupan desa yang tenang.',
    'Desa Kandri, Gunungpati, Semarang',
    ST_SetSRID(ST_MakePoint(110.3555, -7.0655), 4326),
    '081234567001',
    true
),
(
    'hms-gunungpati-002',
    'd2e3f4a5-b6c7-8901-bcde-gunungpati002',
    'Jatirejo Eco Lodge',
    'Penginapan ramah lingkungan di tengah kebun kolang-kaling. Konsep eco-friendly dengan bangunan dari material alami. Termasuk tur kebun dan workshop pembuatan kolang-kaling.',
    'Desa Jatirejo, Gunungpati, Semarang',
    ST_SetSRID(ST_MakePoint(110.3410, -7.0510), 4326),
    '081234567002',
    true
),
(
    'hms-gunungpati-003',
    'd3e4f5a6-b7c8-9012-cdef-gunungpati003',
    'Omah Jawi Guesthouse',
    'Penginapan bergaya Jawa klasik dengan arsitektur joglo. Dilengkapi dengan gamelan untuk tamu yang ingin belajar. Sarapan menu tradisional Jawa.',
    'Kampung Jawi, Gunungpati, Semarang',
    ST_SetSRID(ST_MakePoint(110.3675, -7.0535), 4326),
    '081234567003',
    true
)
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- ROOMS
-- ==========================================

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Kamar Desa', 150000, 2, ARRAY['Fan', 'Breakfast', 'Shared Bathroom'], 3
FROM homestays h WHERE h.id = 'hms-gunungpati-001';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Kamar Keluarga', 250000, 4, ARRAY['Fan', 'Breakfast', 'Private Bathroom'], 2
FROM homestays h WHERE h.id = 'hms-gunungpati-001';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Eco Room Standard', 175000, 2, ARRAY['Natural Ventilation', 'Breakfast', 'Tour Included'], 4
FROM homestays h WHERE h.id = 'hms-gunungpati-002';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Eco Room Deluxe', 300000, 2, ARRAY['AC', 'Breakfast', 'Tour Included', 'Workshop'], 2
FROM homestays h WHERE h.id = 'hms-gunungpati-002';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Kamar Joglo', 350000, 2, ARRAY['AC', 'Breakfast', 'Traditional Decor', 'Gamelan Access'], 2
FROM homestays h WHERE h.id = 'hms-gunungpati-003';

INSERT INTO rooms (homestay_id, name, price_per_night, capacity, amenities, stock)
SELECT h.id, 'Kamar Pendopo', 500000, 4, ARRAY['AC', 'Breakfast', 'Living Room', 'Traditional Decor', 'Cultural Tour'], 1
FROM homestays h WHERE h.id = 'hms-gunungpati-003';

-- ==========================================
-- VERIFY DATA
-- ==========================================

-- Lihat semua desa di Gunungpati
SELECT name, district, province FROM villages WHERE district = 'Gunungpati';

-- Lihat semua objek wisata per desa
SELECT v.name as desa, a.name as wisata, a.category, a.price, a.rating
FROM villages v
JOIN attractions a ON a.village_id = v.id
WHERE v.district = 'Gunungpati'
ORDER BY v.name, a.category;

-- Lihat homestay dan kamar
SELECT h.name as homestay, r.name as room, r.price_per_night, r.capacity
FROM homestays h
JOIN rooms r ON r.homestay_id = h.id
ORDER BY h.name, r.price_per_night;

-- Test geofencing di Desa Kandri
SELECT name FROM check_geofence(-7.065, 110.355);

-- Test nearby attractions dari pusat Kandri (radius 5km)
SELECT name, category, ROUND(distance_meters::numeric) as jarak_meter 
FROM get_nearby_attractions(-7.065, 110.355, 5000)
ORDER BY distance_meters;

-- ============================================================
-- SELESAI! Data wisata Gunungpati berhasil ditambahkan
-- Total: 3 Desa Wisata, 12 Objek Wisata, 3 Homestay, 6 Kamar
-- ============================================================
