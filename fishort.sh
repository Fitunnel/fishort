#!/bin/bash

# Folder Proyek & File
DIR="$HOME/shortlink"
CONFIG="$DIR/Caddyfile"
INDEX="$DIR/index.php"
DB="$DIR/links.db"
DOMAIN_FILE="$DIR/domain.txt"

# Warna
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_menu() {
    clear
    echo -e "${BLUE}=======================================${NC}"
    echo -e "${YELLOW}      FISHORT - ALFINET PANEL        ${NC}"
    echo -e "${BLUE}=======================================${NC}"
    echo -e "1) Install & Auto-Setup (Semua File)"
    echo -e "2) Atur Domain / Subdomain"
    echo -e "3) Jalankan Server (ON)"
    echo -e "4) Matikan Server (OFF)"
    echo -e "5) Ambil Target CNAME (ID Tunnel)"
    echo -e "6) Manajemen Link (Lihat & Hapus)"
    echo -e "7) Reset/Hapus Semua Proyek"
    echo -e "8) Keluar"
    echo -e "${BLUE}=======================================${NC}"
    read -p "Pilih menu [1-8]: " pilihan
}

while true; do
    show_menu
    case $pilihan in
        1)
            echo -e "${GREEN}Menginstal paket sistem...${NC}"
            pkg update && pkg upgrade -y
            pkg install php php-fpm caddy cloudflared sqlite screen nano -y
            mkdir -p $DIR
            
            # Auto-Create Caddyfile
            echo -e ":8080 {\n    root * $DIR\n    php_fastcgi unix//data/data/com.termux/files/usr/var/run/php-fpm.sock\n    file_server\n}" > $CONFIG
            
            # Auto-Create index.php
            cat <<EOF > $INDEX
<?php
\$db = new PDO('sqlite:links.db');
\$db->exec("CREATE TABLE IF NOT EXISTS links (id INTEGER PRIMARY KEY, code TEXT, url TEXT, expires_at DATETIME)");
\$db->exec("DELETE FROM links WHERE expires_at < DATETIME('now') AND expires_at IS NOT NULL");
\$message = "";
if (\$_SERVER['REQUEST_METHOD'] === 'POST' && !empty(\$_POST['url'])) {
    \$url = \$_POST['url'];
    \$custom = trim(\$_POST['custom']);
    \$days = (int)\$_POST['expiry'];
    \$code = !empty(\$custom) ? preg_replace('/[^a-zA-Z0-9]/', '', \$custom) : substr(md5(uniqid()), 0, 5);
    \$expiry_date = (\$days > 0) ? date('Y-m-d H:i:s', strtotime("+\$days days")) : null;
    \$check = \$db->prepare("SELECT id FROM links WHERE code = ?");
    \$check->execute([\$code]);
    if (\$check->fetch()) { \$message = "<div style='color:red;'>Kode '\$code' sudah ada!</div>"; }
    else {
        \$stmt = \$db->prepare("INSERT INTO links (code, url, expires_at) VALUES (?, ?, ?)");
        \$stmt->execute([\$code, \$url, \$expiry_date]);
        \$domain = file_get_contents('domain.txt') ?: 'localhost';
        \$short = "https://".trim(\$domain)."/".\$code;
        \$message = "<div style='color:green;'>Berhasil! Link: <br><input type='text' value='\$short' readonly onclick='this.select()' style='width:100%; text-align:center;'></div>";
    }
}
\$path = trim(\$_SERVER['REQUEST_URI'], '/');
if (\$path && !strpos(\$path, '.php')) {
    \$stmt = \$db->prepare("SELECT url FROM links WHERE code = ?");
    \$stmt->execute([\$path]);
    \$row = \$stmt->fetch();
    if (\$row) { header("Location: " . \$row['url']); exit; }
}
?>
<!DOCTYPE html><html><head><title>Fishort</title><meta name='viewport' content='width=device-width,initial-scale=1'><style>body{font-family:sans-serif;background:#f0f2f5;display:flex;justify-content:center;align-items:center;min-height:100vh;margin:0}.card{background:white;padding:25px;border-radius:15px;box-shadow:0 8px 20px rgba(0,0,0,0.1);width:90%;max-width:350px;text-align:center}input,select,button{width:100%;padding:12px;margin:8px 0;border-radius:8px;border:1px solid #ddd;box-sizing:border-box}button{background:#007bff;color:white;border:none;font-weight:bold;cursor:pointer;transition:0.3s}button:hover{background:#0056b3}</style></head>
<body><div class='card'><h2>Fishort</h2><?=\$message?><form method='post'><input type='url' name='url' placeholder='Tempel URL Panjang' required><input type='text' name='custom' placeholder='Nama Custom (Contoh: uwu)'><select name='expiry'><option value='0'>Masa Berlaku: Selamanya</option><option value='3'>3 Hari</option><option value='7'>7 Hari</option><option value='15'>15 Hari</option><option value='30'>30 Hari</option></select><button type='submit'>Pendekkan Sekarang!</button></form></div></body></html>
EOF
            chmod 777 $DIR
            echo -e "${GREEN}Instalasi & Auto-Setup Selesai!${NC}"
            sleep 2
            ;;
        2)
            read -p "Masukkan Domain (alfinet.my.id): " MY_DOMAIN
            echo "$MY_DOMAIN" > "$DOMAIN_FILE"
            echo -e "${GREEN}Domain disimpan!${NC}"
            sleep 1
            ;;
        3)
            DOMAIN=$(cat "$DOMAIN_FILE" 2>/dev/null)
            if [ -z "$DOMAIN" ]; then
                echo -e "${RED}Error: Set domain dulu di menu 2!${NC}"
            else
                echo -e "${GREEN}Menyalakan Server...${NC}"
                pkill php-fpm; pkill caddy; pkill cloudflared
                php-fpm
                caddy start --config $CONFIG
                screen -dmS tunnel cloudflared tunnel run --url http://localhost:8080 termux-shortlink
                echo -e "${GREEN}✅ SERVER ONLINE: https://$DOMAIN${NC}"
            fi
            sleep 2
            ;;
        4)
            pkill php-fpm; pkill caddy; pkill cloudflared
            echo -e "${RED}🛑 Server OFFLINE${NC}"
            sleep 1
            ;;
        5)
            ID_RAW=$(cloudflared tunnel list | grep "termux-shortlink" | awk '{print $1}')
            if [ -z "$ID_RAW" ]; then
                echo -e "${RED}Tunnel tidak ditemukan.${NC}"
            else
                echo -e "${GREEN}${ID_RAW}.cfargotunnel.com${NC}"
            fi
            read -p "Tekan Enter..."
            ;;
        6)
            echo -e "${YELLOW}--- DAFTAR LINK AKTIF ---${NC}"
            if [ ! -f "$DB" ]; then
                echo -e "${RED}Belum ada link yang dibuat.${NC}"
            else
                # Menampilkan data dari SQLite
                sqlite3 "$DB" "SELECT id, code, url, expires_at FROM links;" | sed 's/|/  |  /g'
                echo -e "${BLUE}---------------------------------------${NC}"
                echo -e "Ingin menghapus link? Masukkan ID-nya."
                read -p "ID yang mau dihapus (kosongkan jika batal): " DEL_ID
                if [ ! -z "$DEL_ID" ]; then
                    sqlite3 "$DB" "DELETE FROM links WHERE id=$DEL_ID;"
                    echo -e "${RED}Link ID $DEL_ID berhasil dihapus!${NC}"
                fi
            fi
            read -p "Tekan Enter..."
            ;;
        7)
            read -p "Yakin hapus semua? (y/n): " confirm
            [[ "$confirm" == "y" ]] && rm -rf $DIR && echo "Dihapus."
            sleep 1
            ;;
        8) exit 0 ;;
    esac
done
