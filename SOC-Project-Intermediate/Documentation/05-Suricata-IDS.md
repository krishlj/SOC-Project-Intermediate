# 05 — Suricata IDS Sensor

## Objective

Install Suricata on the dedicated Ubuntu IDS instance and confirm that it produces EVE JSON events.

## 1. Connect and update

```bash
ssh -i soc-lab-key.pem ubuntu@IDS_PUBLIC_IP
sudo apt update
sudo apt install -y software-properties-common jq ethtool tcpdump
```

## 2. Install the latest stable Suricata package

```bash
sudo add-apt-repository -y ppa:oisf/suricata-stable
sudo apt update
sudo apt install -y suricata jq
```

Verify:

```bash
suricata --build-info
sudo systemctl status suricata --no-pager
```

## 3. Identify the interface

```bash
ip -br link
ip -br address
```

AWS Ubuntu instances commonly use `ens5`, but always use the actual interface shown on your instance.

## 4. Configure HOME_NET

Back up:

```bash
sudo cp /etc/suricata/suricata.yaml \
  /etc/suricata/suricata.yaml.backup
```

Edit:

```bash
sudo nano /etc/suricata/suricata.yaml
```

Set:

```yaml
vars:
  address-groups:
    HOME_NET: "[10.0.0.0/16]"
```

## 5. Confirm EVE JSON

Ensure the `eve-log` output is enabled:

```yaml
outputs:
  - eve-log:
      enabled: yes
      filetype: regular
      filename: eve.json
      types:
        - alert
        - anomaly
        - http
        - dns
        - tls
        - flow
```

## 6. Install a safe custom rule

Copy:

```text
Detection-Rules/suricata-local.rules
```

to:

```text
/etc/suricata/rules/local.rules
```

Confirm `suricata.yaml` includes:

```yaml
rule-files:
  - suricata.rules
  - local.rules
```

## 7. Update community rules

```bash
sudo suricata-update
```

## 8. Validate configuration

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
```

Do not restart until the test succeeds.

## 9. Restart and verify

```bash
sudo systemctl enable suricata
sudo systemctl restart suricata
sudo systemctl status suricata --no-pager
sudo ls -lh /var/log/suricata/
sudo tail -n 5 /var/log/suricata/eve.json | jq .
```

## Important AWS note

VPC Traffic Mirroring sends VXLAN-encapsulated traffic to the IDS target on UDP port `4789`. The IDS security group must allow this traffic from the mirror source. Suricata must receive or decode the mirrored packets correctly; the traffic-mirroring guide covers the AWS configuration.

## Common errors

### `suricata.service` fails

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml -v
sudo journalctl -u suricata -n 100 --no-pager
```

Most failures are YAML indentation errors, an incorrect interface name or a bad rule.

### `eve.json` is missing

```bash
sudo grep -n "eve-log" /etc/suricata/suricata.yaml
sudo systemctl restart suricata
sudo find /var/log/suricata -maxdepth 1 -type f -ls
```

### No mirrored packets arrive

```bash
sudo tcpdump -ni any udp port 4789
```

If no packets appear, verify the mirror session, source ENI, target ENI, filter rules, routing and IDS security group.
