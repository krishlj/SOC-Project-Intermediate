#!/usr/bin/env bash
set -euo pipefail

WAZUH_MINOR="${WAZUH_MINOR:-4.14}"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0"
  exit 1
fi

echo "[1/5] Checking memory and disk"
free -h
df -h /

MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
if (( MEM_KB < 7500000 )); then
  echo "WARNING: Less than approximately 8 GB RAM detected."
  echo "An all-in-one Wazuh lab may fail or perform poorly."
fi

echo "[2/5] Installing prerequisites"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip tar gnupg apt-transport-https

echo "[3/5] Downloading official Wazuh installation assistant"
curl -fsSLO "https://packages.wazuh.com/${WAZUH_MINOR}/wazuh-install.sh"
chmod 750 wazuh-install.sh

echo "[4/5] Starting all-in-one installation"
bash ./wazuh-install.sh -a

echo "[5/5] Service status"
systemctl --no-pager --full status wazuh-manager || true
systemctl --no-pager --full status wazuh-indexer || true
systemctl --no-pager --full status wazuh-dashboard || true

echo "Installation finished. Store credentials securely and restrict TCP 443 to your IP."
