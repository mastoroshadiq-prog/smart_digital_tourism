# 🏞️ DesaExplore - Smart Digital Tourism

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase">
  <img src="https://img.shields.io/badge/PostGIS-Geofencing-336791?logo=postgresql" alt="PostGIS">
  <img src="https://img.shields.io/badge/Android-6.0+-3DDC84?logo=android" alt="Android">
</p>

**DesaExplore** adalah aplikasi pariwisata desa cerdas berbasis **Geofencing** yang memberikan informasi kontekstual kepada wisatawan saat memasuki wilayah desa wisata. Dibangun dengan Flutter untuk mobile/web dan Supabase + PostGIS untuk backend.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🗺️ **Geofencing** | Deteksi otomatis saat wisatawan memasuki area desa wisata |
| 📍 **Interactive Map** | Peta interaktif dengan polygon desa dan marker wisata |
| 🏡 **Desa Wisata** | Informasi lengkap desa wisata dengan objek wisata |
| 🎫 **E-Ticket** | Sistem tiket digital dengan QR Code |
| 🏠 **Homestay Booking** | Pemesanan penginapan lokal |
| 📱 **Offline Mode** | Akses data penting tanpa koneksi internet |
| 🔔 **Push Notification** | Notifikasi saat memasuki area wisata |

---

## 🛠️ Tech Stack

### Frontend (Flutter)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Maps:** flutter_map + OpenStreetMap
- **Storage:** Hive (offline cache)
- **UI:** Material 3 + Google Fonts

### Backend (Supabase)
- **Database:** PostgreSQL + PostGIS
- **Auth:** Supabase Auth
- **API:** Supabase Client + REST
- **Spatial Queries:** ST_Contains, ST_DWithin

---

## 📱 Screenshots

> *Coming soon*

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Supabase Account

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/mastoroshadiq-prog/smart_digital_tourism.git
   cd smart_digital_tourism
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Buat project di [Supabase](https://supabase.com)
   - Jalankan SQL di folder `context/`:
     - `supabase_setup.sql` (schema & functions)
     - `data_gunungpati.sql` (sample data)

4. **Configure credentials**
   
   Edit `lib/core/config/env_config.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

5. **Run the app**
   ```bash
   # Web
   flutter run -d chrome
   
   # Android
   flutter run -d android
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp config
├── core/
│   ├── config/               # App & env configuration
│   ├── theme/                # Colors & themes
│   └── router/               # GoRouter navigation
├── data/
│   ├── models/               # Data models
│   └── services/             # Supabase, Location, Storage
├── providers/                # Riverpod state management
└── presentation/screens/     # UI screens
```

---

## 🗄️ Database Schema

| Table | Description |
|-------|-------------|
| `users` | User accounts with roles |
| `villages` | Desa wisata with polygon areas |
| `attractions` | Objek wisata with location points |
| `homestays` | Accommodations |
| `rooms` | Room types & pricing |
| `transactions` | Booking transactions |
| `transaction_items` | E-tickets & bookings |

### Key Functions
- `check_geofence(lat, lon)` - Detect user in village area
- `get_nearby_attractions(lat, lon, radius)` - Find nearby POIs

---

## 🌍 Sample Data: Gunungpati, Semarang

Aplikasi ini dilengkapi dengan data wisata **Kecamatan Gunungpati, Kota Semarang**:

| Kategori | Jumlah |
|----------|--------|
| Desa Wisata | 3 (Kandri, Jatirejo, Kampung Jawi) |
| Objek Wisata | 12 (Gua Kreo, Waduk Jatibarang, dll) |
| Homestay | 3 |

---

## 📄 Documentation

- [SRS Document](context/SRS_Smart%20Digital%20Tourism.md)
- [Database Design](context/Database%20Design%20Document.md)
- [SQL Setup](context/supabase_setup.sql)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

---

## 👨‍💻 Author

**Masto Roshadiq**

---

<p align="center">
  Made with ❤️ for Indonesian Village Tourism
</p>
