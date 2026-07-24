#!/usr/bin/env bash
set -euo pipefail

HOME_NET_CIDR="${HOME_NET_CIDR:-10.0.0.0/16}"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo HOME_NET_CIDR=10.0.0.0/16 bash $0"
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common jq ethtool tcpdump
add-apt-repository -y ppa:oisf/suricata-stable
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y suricata jq

cp /etc/suricata/suricata.yaml "/etc/suricata/suricata.yaml.backup.$(date +%F-%H%M%S)"

python3 - <<PY
from pathlib import Path
p = Path("/etc/suricata/suricata.yaml")
s = p.read_text()
s = s.replace('HOME_NET: "[192.168.0.0/16,10.0.0.0/8,172.16.0.0/12]"',
              'HOME_NET: "[${HOME_NET_CIDR}]"')
p.write_text(s)
PY

suricata-update
suricata -T -c /etc/suricata/suricata.yaml -v
systemctl enable suricata
systemctl restart suricata
systemctl --no-pager --full status suricata || true

echo "Copy Detection-Rules/suricata-local.rules to /etc/suricata/rules/local.rules"
echo "Then confirm local.rules is listed under rule-files and re-run the config test."
