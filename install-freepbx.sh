#!/bin/bash
set -e

echo "[+] Updating system and installing base packages"
apt update && apt upgrade -y
apt install -y sudo curl wget gnupg2 ca-certificates lsb-release net-tools vim git cron

echo "[+] Installing MariaDB server"
apt install -y mariadb-server
mysqld_safe --skip-syslog &

echo "[+] Setting up the database"
sleep 5
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS asterisk DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'asteriskuser'@'localhost' IDENTIFIED BY 'strongpassword';
GRANT ALL PRIVILEGES ON asterisk.* TO 'asteriskuser'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "[+] Installing Apache and PHP 8.2"
apt install -y apache2
apache2ctl start
apt install -y php php-cli php-mysql php-curl php-mbstring php-xml php-zip \
php-bcmath php-gd php-soap php-intl libapache2-mod-php

echo "[+] Installing Asterisk from source"
apt install -y build-essential git autoconf subversion libtool libxml2-dev uuid-dev \
libjansson-dev libsqlite3-dev libedit-dev

cd /usr/src
git clone -b 20 https://github.com/asterisk/asterisk.git asterisk
cd asterisk
contrib/scripts/install_prereq install
./configure
make -j$(nproc)
make install
make samples
ldconfig

echo "[+] Adding asterisk user and setting permissions"
adduser asterisk --disabled-password --gecos "" || echo "[*] User already exists"
mkdir -p /var/run/asterisk
chown -R asterisk:asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib/asterisk /var/run/asterisk

echo "[+] Starting Asterisk in background"
sudo -u asterisk asterisk -T -f &
sleep 5

echo "[+] Installing NodeJS"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[+] Installing FreePBX"
cd /usr/src
wget https://mirror.freepbx.org/modules/packages/freepbx/freepbx-17.0-latest.tgz
tar xfz freepbx-17.0-latest.tgz
cd freepbx
./start_asterisk start
./install -n

echo "[✓] FreePBX installation complete and ready to use"


# keep container running ONLY if launched directly
if [[ "$1" == "--wait" ]]; then
  tail -f /dev/null
else
  exit 0
fi
