# **Software Requirements Specification (SRS)**

**Proyek:** Smart Digital Tourism (Code Name: DesaExplore)

**Versi:** 1.0

**Status:** Draft Awal

**Tanggal:** 11 Desember 2025

## **1\. Pendahuluan**

### **1.1 Tujuan**

Dokumen ini mendeskripsikan kebutuhan perangkat lunak untuk aplikasi "Smart Digital Tourism". Aplikasi ini bertujuan mempromosikan pariwisata desa dengan fitur unggulan deteksi lokasi otomatis (Geofencing) untuk memberikan informasi kontekstual kepada wisatawan saat memasuki wilayah desa.

### **1.2 Lingkup Produk**

Sistem akan mencakup:

1. **Mobile App (Android/iOS):** Untuk wisatawan (Discovery, Booking, Navigation).  
2. **Web Admin/Dashboard:** Untuk pengelola desa dan super admin (CMS, Manajemen Transaksi, Laporan).  
3. **Backend Services:** API Server, Location Service, dan Database Spasial.

### **1.3 Definisi & Akronim**

* **Geofencing:** Teknologi untuk menetapkan batas virtual geografis.  
* **POI (Point of Interest):** Titik lokasi wisata, fasilitas umum, dll.  
* **MVP (Minimum Viable Product):** Versi produk dengan fitur dasar yang cukup untuk dirilis.

## **2\. Deskripsi Umum**

### **2.1 Karakteristik Pengguna**

| Aktor | Deskripsi |
| :---- | :---- |
| **Wisatawan** | Pengguna umum yang mencari wisata, membeli tiket, dan menggunakan fitur peta. |
| **Admin Desa** | Pengelola lokal yang memverifikasi tiket dan mengupdate konten desa. |
| **Mitra (Homestay)** | Pemilik penginapan yang mengelola ketersediaan kamar. |
| **Super Admin** | Pengelola sistem pusat. |

### **2.2 Asumsi & Ketergantungan**

* Pengguna mengizinkan akses lokasi (GPS) pada perangkat mobile.  
* Koneksi internet tersedia (minimal edge/3G) untuk sinkronisasi awal, namun aplikasi mendukung mode semi-offline.  
* Peta digital menggunakan layanan pihak ketiga (Mapbox/Google Maps).

## **3\. Spesifikasi Fungsional**

### **3.1 Modul Lokasi & Navigasi (Core Feature)**

**FR-LOC-01: Deteksi Wilayah Desa (Geofencing)**

* Sistem harus mampu mendeteksi koordinat GPS pengguna secara real-time atau background periodik.  
* Sistem harus membandingkan posisi pengguna dengan *polygon* batas wilayah desa di database.  
* Jika pengguna masuk (ST\_Contains bernilai true), sistem mengirimkan *Push Notification* sambutan dan info desa.

**FR-LOC-02: Nearby Attractions**

* Sistem menampilkan daftar wisata dalam radius X km dari posisi pengguna.

### **3.2 Modul Konten & Informasi**

**FR-INFO-01: Detail Desa & Wisata**

* Menampilkan galeri foto, video, deskripsi sejarah, dan panduan budaya.  
* Informasi fasilitas umum (Toilet, Masjid, ATM).

**FR-INFO-02: Offline Mode**

* Aplikasi harus menyimpan data penting (tiket aktif, info dasar desa) di penyimpanan lokal (*Local Storage*) agar dapat diakses tanpa sinyal.

### **3.3 Modul Transaksi (Booking)**

**FR-TRX-01: Pembelian Tiket Wisata**

* Pengguna dapat membeli tiket masuk (Generate QR Code).  
* Integrasi Payment Gateway (QRIS, VA, E-Wallet).

**FR-TRX-02: Reservasi Homestay**

* Cek ketersediaan kamar berdasarkan tanggal.  
* Booking dan pembayaran uang muka (DP) atau lunas.

### **3.4 Modul Panduan (Guide)**

FR-GUIDE-01: List profil pemandu lokal berlisensi.  
FR-GUIDE-02: Fitur "Click to Chat" (integrasi WhatsApp API) ke pemandu.

## **4\. Spesifikasi Antarmuka Eksternal**

### **4.1 Antarmuka Pengguna (UI)**

* **Mobile:** Menggunakan Flutter (Material Design / Cupertino). Responsif untuk berbagai ukuran layar HP.  
* **Web:** Dashboard responsif untuk Admin.

### **4.2 Antarmuka Perangkat Keras**

* GPS Sensor (Wajib).  
* Kamera (Untuk scan QR Code tiket oleh Admin).

## **5\. Kebutuhan Non-Fungsional**

### **5.1 Performa**

* Query lokasi spasial harus dieksekusi di bawah 200ms.  
* Aplikasi mobile harus *startup* di bawah 3 detik.

### **5.2 Keamanan**

* Semua komunikasi API menggunakan HTTPS.  
* Password di-hash menggunakan bcrypt/argon2.  
* Data lokasi pengguna tidak boleh disimpan permanen (hanya log anonim untuk analitik panas wilayah).

### **5.3 Keandalan**

* Sistem harus tetap dapat menampilkan tiket yang sudah dibeli meskipun server down atau offline (Client-side persistence).

## **6\. Stack Teknologi**

* **Mobile/Web Apps:** Flutter (Dart).  
* **Backend:** Golang / Node.js.  
* **Database:** PostgreSQL \+ PostGIS Extension.  
* **Maps:** Mapbox GL / Google Maps SDK.  
* **Cloud Storage:** S3 Compatible Storage (MinIO/AWS).