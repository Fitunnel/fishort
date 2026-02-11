# 🐟 Fishort (Fitunnel Shortener)
**Fishort** adalah skrip manajemen URL Shortener premium yang dirancang khusus untuk dijalankan di **Termux (Android)**. Proyek ini memungkinkan Anda memiliki layanan pemendek link sendiri dengan domain kustom tanpa memerlukan VPS, memanfaatkan teknologi **Caddy Server** dan **Cloudflare Tunnel**.

## 🌟 Fitur Utama
- ✅ **Setup Otomatis**: Instalasi seluruh *environment* (PHP, Caddy, SQLite) hanya dengan satu klik.
- 🔗 **Custom Alias**: Membuat link pendek dengan kata-kata pilihan sendiri.
- ⏳ **Masa Berlaku (Expiry)**: Link bisa diatur agar terhapus otomatis (3, 7, 15, atau 30 hari).
- 🛡️ **Admin Dashboard**: Lihat semua daftar link yang aktif dan hapus link yang melanggar aturan langsung dari menu terminal.
- ☁️ **Cloudflare Integration**: Fitur cerdas untuk mendeteksi ID Tunnel dan memberikan target DNS yang siap salin.
- 🎨 **Responsive UI**: Tampilan website yang bersih dan modern (Mobile Friendly).

## 🛠️ Prasyarat
- Aplikasi [Termux](https://f-droid.org/en/packages/com.termux/) (Versi F-Droid direkomendasikan).
- Domain yang sudah aktif di **Cloudflare**.
- Tunnel yang sudah dikonfigurasi di Cloudflare Zero Trust.

## 🚀 Instalasi Cepat
Salin dan tempel perintah ini di terminal Termux Anda:

```
pkg update && pkg upgrade -y
pkg install git -y
git clone https://github.com/Fitunnel/fishort
cd fishort
chmod +x fishort.sh
./fishort.sh
```

### jalankan
jalankan mengunakan domain yang anda masukan lalu buka browser nya dan boom!
