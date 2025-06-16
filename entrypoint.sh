#!/bin/bash
set -e

echo "[ENTRYPOINT] Starting MariaDB..."
mysqld_safe --skip-syslog &

echo "[ENTRYPOINT] Starting Apache..."
apache2ctl start

echo "[ENTRYPOINT] Starting Asterisk as 'asterisk' user..."
mkdir -p /var/run/asterisk
chown -R asterisk:asterisk /var/run/asterisk
runuser -l asterisk -c 'asterisk -T -f' &

echo "[ENTRYPOINT] All services started. Container is now running."
tail -f /dev/null
