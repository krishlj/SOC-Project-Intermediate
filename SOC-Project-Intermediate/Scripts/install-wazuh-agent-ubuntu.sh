#!/usr/bin/env bash
set -euo pipefail

: "${WAZUH_MANAGER_IP:?Set WAZUH_MANAGER_IP to the Wazuh private IP}"
WAZUH_AGENT_NAME="${WAZUH_AGENT_NAME:-$(hostname)}"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo and preserve variables:"
  echo "sudo WAZUH_MANAGER_IP=10.0.1.10 bash $0"
  exit 1
fi

echo "[1/6] Installing prerequisites"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y curl gnupg apt-transport-https

echo "[2/6] Importing Wazuh signing key"
mkdir -p /usr/share/keyrings
rm -f /usr/share/keyrings/wazuh.gpg
curl -fsS https://packages.wazuh.com/key/GPG-KEY-WAZUH \
  | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
chmod 644 /usr/share/keyrings/wazuh.gpg

echo "[3/6] Adding Wazuh repository"
cat > /etc/apt/sources.list.d/wazuh.list <<'EOF'
deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main
EOF

echo "[4/6] Installing Wazuh agent"
apt-get update
WAZUH_MANAGER="${WAZUH_MANAGER_IP}" \
WAZUH_REGISTRATION_SERVER="${WAZUH_MANAGER_IP}" \
WAZUH_AGENT_NAME="${WAZUH_AGENT_NAME}" \
  apt-get install -y wazuh-agent

echo "[5/6] Starting service"
systemctl daemon-reload
systemctl enable --now wazuh-agent

echo "[6/6] Validation"
systemctl --no-pager --full status wazuh-agent || true
tail -n 30 /var/ossec/logs/ossec.log || true

echo "Note: Keep the agent version equal to or older than the Wazuh manager version."
