# 10 — Troubleshooting Guide

Follow the data path in order. Do not change multiple components at once.

## Layer 1 — AWS network

### Linux instance has no internet

```bash
ip route
curl -I https://example.com
```

Check:

- public IPv4 assigned
- subnet route table has `0.0.0.0/0 → IGW`
- network ACL allows return traffic
- security group allows outbound HTTPS
- DNS resolution is enabled for the VPC

### SSH timeout

- port 22 source must be your current public IP `/32`
- use the correct username (`ubuntu` for Ubuntu)
- use the correct key
- confirm instance status checks passed

## Layer 2 — Wazuh server

```bash
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard filebeat --no-pager
sudo journalctl -u wazuh-manager -n 100 --no-pager
sudo journalctl -u wazuh-dashboard -n 100 --no-pager
sudo ss -lntp | grep -E ':(443|1514|1515|55000)\b'
```

### Dashboard says “No agents”

1. Confirm the manager private IP configured on the endpoint.
2. Confirm agent service is running.
3. Test TCP 1514 and 1515.
4. Check the endpoint agent log.
5. Check the manager agent list:

```bash
sudo /var/ossec/bin/agent_control -lc
```

## Layer 3 — Windows endpoint

```powershell
Get-Service wazuhsvc
Test-NetConnection WAZUH_PRIVATE_IP -Port 1514
Test-NetConnection WAZUH_PRIVATE_IP -Port 1515
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 100
```

### Duplicate agent name

Remove the old inactive registration in the dashboard or use a unique `WAZUH_AGENT_NAME`, then reinstall or re-enroll the agent.

## Layer 4 — Ubuntu or IDS Wazuh agent

```bash
sudo systemctl status wazuh-agent --no-pager
sudo tail -n 100 /var/ossec/logs/ossec.log
sudo grep -n "<address>" /var/ossec/etc/ossec.conf
```

## Layer 5 — Suricata

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
sudo systemctl status suricata --no-pager
sudo journalctl -u suricata -n 100 --no-pager
sudo tail -n 20 /var/log/suricata/eve.json
```

### Rule syntax error

Test only the rule file:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml \
  -S /etc/suricata/rules/local.rules
```

### No mirrored traffic

```bash
sudo tcpdump -ni any udp port 4789
```

If empty, troubleshoot AWS Traffic Mirroring. If VXLAN appears but no Suricata alert appears, review capture configuration and rule matching.

## Layer 6 — Wazuh ingestion of `eve.json`

```bash
sudo grep -n -A3 -B2 "suricata/eve.json" /var/ossec/etc/ossec.conf
sudo tail -n 100 /var/ossec/logs/ossec.log
sudo test -r /var/log/suricata/eve.json && echo readable
```

## Safe rollback

Before changing configuration:

```bash
sudo cp FILE FILE.backup.$(date +%F-%H%M%S)
```

Validate XML:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
```

Validate Suricata YAML and rules:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```

Restart services only after validation succeeds.
