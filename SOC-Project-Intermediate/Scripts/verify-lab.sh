#!/usr/bin/env bash
set -u

echo "=== Host ==="
hostnamectl || true
echo

echo "=== IP addresses ==="
ip -br address || true
echo

echo "=== Wazuh agent ==="
systemctl is-active wazuh-agent 2>/dev/null || echo "not installed or inactive"
test -f /var/ossec/logs/ossec.log && tail -n 20 /var/ossec/logs/ossec.log
echo

echo "=== Auditd ==="
systemctl is-active auditd 2>/dev/null || echo "not installed or inactive"
echo

echo "=== Suricata ==="
systemctl is-active suricata 2>/dev/null || echo "not installed or inactive"
test -f /var/log/suricata/eve.json && tail -n 3 /var/log/suricata/eve.json
