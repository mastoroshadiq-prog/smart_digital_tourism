# **Database Design Document**

**Proyek:** Smart Digital Tourism

**Database Engine:** PostgreSQL 14+

**Extensions:** PostGIS, UUID-OSSP

## **1\. Pendahuluan Teknis**

Database ini dirancang untuk menangani data relasional standar (pengguna, transaksi) dan data spasial geografis yang kompleks (peta wilayah, lokasi koordinat). Penggunaan ekstensi **PostGIS** adalah mandatori.

### **1.1 Prasyarat Ekstensi**

Perintah SQL berikut harus dijalankan pertama kali saat inisialisasi database:

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  
CREATE EXTENSION IF NOT EXISTS "postgis";

## **2\. Entity Relationship Diagram (ERD) Overview**

Secara garis besar, relasi antar tabel adalah sebagai berikut:

* Villages (Desa) adalah entitas induk geografis.  
* Attractions dan Homestays bergantung pada Villages.  
* Users melakukan Transactions.  
* Transactions memiliki banyak Transaction\_Items (Detail belanja).

## **3\. Definisi Skema Tabel (DDL)**

### **3.1 Tabel Users (Pengguna)**

Menyimpan data otentikasi dan profil semua tipe pengguna.

CREATE TYPE user\_role\_enum AS ENUM ('tourist', 'village\_admin', 'homestay\_owner', 'super\_admin');

CREATE TABLE users (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    full\_name VARCHAR(100) NOT NULL,  
    email VARCHAR(100) UNIQUE NOT NULL,  
    password\_hash VARCHAR(255) NOT NULL,  
    phone\_number VARCHAR(20),  
    role user\_role\_enum DEFAULT 'tourist',  
    fcm\_token TEXT, \-- Untuk Push Notification (Firebase)  
    created\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP,  
    updated\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP  
);

### **3.2 Tabel Villages (Desa Wisata) \- Spatial Core**

Menyimpan data administratif dan geografis desa. Kolom area\_polygon adalah kunci fitur Geofencing.

CREATE TABLE villages (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    name VARCHAR(100) NOT NULL,  
    slug VARCHAR(100) UNIQUE NOT NULL, \-- Untuk URL friendly  
    description TEXT,  
    district VARCHAR(100), \-- Kecamatan  
    province VARCHAR(100),  
      
    \-- GEOMETRY: Menyimpan batas wilayah desa (Polygon). SRID 4326 (WGS84)  
    area\_polygon GEOMETRY(POLYGON, 4326\) NOT NULL,  
    center\_point GEOMETRY(POINT, 4326),  
      
    created\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP  
);

\-- Index Spasial (PENTING untuk performa query lokasi)  
CREATE INDEX idx\_villages\_area ON villages USING GIST (area\_polygon);

### **3.3 Tabel Attractions (Objek Wisata)**

Menyimpan POI (Point of Interest) di dalam desa.

CREATE TYPE attraction\_category\_enum AS ENUM ('nature', 'culture', 'artificial', 'culinary');

CREATE TABLE attractions (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    village\_id UUID NOT NULL REFERENCES villages(id) ON DELETE CASCADE,  
    name VARCHAR(150) NOT NULL,  
    description TEXT,  
    category attraction\_category\_enum NOT NULL,  
    price DECIMAL(10, 2\) DEFAULT 0,  
      
    \-- GEOMETRY: Titik koordinat spesifik wisata  
    location\_point GEOMETRY(POINT, 4326\) NOT NULL,  
      
    thumbnail\_url TEXT,  
    gallery\_urls TEXT\[\], \-- Array URL gambar  
    rating DECIMAL(2, 1\) DEFAULT 0,  
    created\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP  
);

CREATE INDEX idx\_attractions\_location ON attractions USING GIST (location\_point);

### **3.4 Tabel Homestays & Rooms (Akomodasi)**

CREATE TABLE homestays (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    village\_id UUID NOT NULL REFERENCES villages(id) ON DELETE CASCADE,  
    owner\_id UUID REFERENCES users(id),  
    name VARCHAR(150) NOT NULL,  
    description TEXT,  
    address TEXT,  
    location\_point GEOMETRY(POINT, 4326),  
    contact\_number VARCHAR(20),  
    is\_active BOOLEAN DEFAULT TRUE,  
    created\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE rooms (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    homestay\_id UUID NOT NULL REFERENCES homestays(id) ON DELETE CASCADE,  
    name VARCHAR(100) NOT NULL,  
    price\_per\_night DECIMAL(10, 2\) NOT NULL,  
    capacity INT DEFAULT 2,  
    amenities TEXT\[\], \-- Contoh: {'WiFi', 'AC', 'Breakfast'}  
    stock INT DEFAULT 1 \-- Jumlah kamar tipe ini  
);

### **3.5 Tabel Transactions (Booking & Tiket)**

CREATE TYPE trx\_status\_enum AS ENUM ('pending', 'paid', 'expired', 'cancelled', 'completed');  
CREATE TYPE item\_type\_enum AS ENUM ('ticket', 'homestay', 'packet');

CREATE TABLE transactions (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    user\_id UUID NOT NULL REFERENCES users(id),  
    invoice\_number VARCHAR(50) UNIQUE NOT NULL, \-- Contoh: INV/2023/10/001  
    total\_amount DECIMAL(12, 2\) NOT NULL,  
    status trx\_status\_enum DEFAULT 'pending',  
    payment\_method VARCHAR(50),  
    payment\_url TEXT,  
    paid\_at TIMESTAMP WITH TIME ZONE,  
    created\_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT\_TIMESTAMP  
);

CREATE TABLE transaction\_items (  
    id UUID PRIMARY KEY DEFAULT uuid\_generate\_v4(),  
    transaction\_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,  
    item\_type item\_type\_enum NOT NULL,  
    reference\_id UUID NOT NULL, \-- ID dari tabel attractions atau rooms  
    quantity INT DEFAULT 1,  
    price\_at\_purchase DECIMAL(10, 2\) NOT NULL,  
    visit\_date DATE NOT NULL,  
      
    \-- Ticket Management  
    ticket\_code VARCHAR(20) UNIQUE, \-- Kode unik untuk scan QR  
    is\_redeemed BOOLEAN DEFAULT FALSE,  
    redeemed\_at TIMESTAMP WITH TIME ZONE  
);

## **4\. Query Kunci (Business Logic)**

### **4.1 Geofencing Trigger Logic**

Query ini dijalankan oleh Backend saat menerima update lokasi dari HP User.  
Input: Lat, Long User.  
SELECT id, name, description   
FROM villages   
WHERE ST\_Contains(  
    area\_polygon,   
    ST\_SetSRID(ST\_MakePoint(:user\_longitude, :user\_latitude), 4326\)  
);

*Jika hasil ditemukan \> 0, kirim Push Notification: "Selamat Datang di Desa \[Name\]\!"*

### **4.2 Mencari Wisata Terdekat (Nearby Feature)**

Mencari wisata dalam radius 5 KM dari user, diurutkan dari yang terdekat.

SELECT name, category, price,   
       ST\_Distance(  
           location\_point::geography,   
           ST\_SetSRID(ST\_MakePoint(:user\_lon, :user\_lat), 4326)::geography  
       ) as distance\_meters  
FROM attractions  
WHERE ST\_DWithin(  
    location\_point::geography,  
    ST\_SetSRID(ST\_MakePoint(:user\_lon, :user\_lat), 4326)::geography,  
    5000 \-- Radius dalam meter  
)  
ORDER BY distance\_meters ASC;  
