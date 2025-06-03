#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Jalankan sebagai root."
    exit 1
fi

echo "=============================="
echo "  Installing LAMP on Debian 11"
echo "=============================="

# Update dan upgrade sistem
apt update && apt upgrade -y

# 1. Install Apache
echo "[+] Installing Apache..."
apt install apache2 -y
systemctl enable apache2
systemctl start apache2

# 2. Install MariaDB (MySQL)
echo "[+] Installing MariaDB..."
apt install mariadb-server mariadb-client -y
systemctl enable mariadb
systemctl start mariadb

# 3. Amankan MariaDB
echo "[+] Securing MariaDB..."
mysql_secure_installation <<EOF

y
rootpassword
rootpassword
y
y
y
y
EOF

# 4. Install PHP dan modul penting
echo "[+] Installing PHP 7.4 and modules..."
apt install php php-mysql libapache2-mod-php php-cli php-curl php-zip php-gd php-mbstring php-xml php-bcmath -y

# 5. Restart Apache untuk memastikan PHP aktif
echo "[+] Restarting Apache..."
systemctl restart apache2

# 6. Tambahkan file info.php untuk test
echo "[+] Creating test PHP file..."
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 7. (Opsional) UFW Firewall
if command -v ufw > /dev/null; then
    echo "[+] Configuring UFW firewall rules..."
    ufw allow 'Apache Full'
    ufw reload
else
    echo "[i] UFW not installed, skipping firewall setup."
fi

echo ""
echo "=============================="
echo "✅ LAMP installation completed!"
echo "=============================="
echo "Cek: http://<IP-Server>/info.php"
echo ""