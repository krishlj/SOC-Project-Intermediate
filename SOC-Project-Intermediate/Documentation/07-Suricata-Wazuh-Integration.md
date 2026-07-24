# 07 — Integrate Suricata with Wazuh

## Data path

```text
Mirrored endpoint traffic
        |
        v
Suricata eve.json
        |
        v
Wazuh agent on IDS sensor
        |
        v
Wazuh manager
        |
        v
Security Events dashboard
```

## 1. Install a Wazuh agent on the IDS sensor

Use the Ubuntu agent helper:

```bash
sudo WAZUH_MANAGER_IP="WAZUH_PRIVATE_IP" \
  bash Scripts/install-wazuh-agent-ubuntu.sh
```

Verify:

```bash
sudo systemctl status wazuh-agent --no-pager
sudo tail -n 100 /var/ossec/logs/ossec.log
```

## 2. Configure EVE JSON collection

Edit:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Add inside `<ossec_config>`:

```xml
<localfile>
  <log_format>json</log_format>
  <location>/var/log/suricata/eve.json</location>
</localfile>
```

Restart:

```bash
sudo systemctl restart wazuh-agent
```

## 3. Confirm local data

```bash
sudo test -s /var/log/suricata/eve.json \
  && echo "eve.json contains events" \
  || echo "eve.json is empty"
```

## 4. Add the optional custom Wazuh rule

On the Wazuh server, copy:

```text
Detection-Rules/wazuh-local_rules.xml
```

into:

```text
/var/ossec/etc/rules/local_rules.xml
```

Back up the existing file first.

Test configuration:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
```

Restart only after the test succeeds:

```bash
sudo systemctl restart wazuh-manager
```

## 5. Generate the benign Suricata test

Follow the safe simulation guide. The custom rule searches for the HTTP path marker:

```text
/SOC-LAB-TEST
```

Expected Suricata signature:

```text
SOC LAB benign HTTP test
```

## 6. Search the Wazuh dashboard

1. Open **Threat Hunting** or **Security events**.
2. Set the time range to **Last 15 minutes**.
3. Search:
   - `suricata`
   - `SOC LAB benign HTTP test`
   - the IDS agent name
4. Open the alert and verify:
   - source IP
   - destination IP
   - destination port
   - signature ID
   - timestamp
   - agent name

## No alerts in Wazuh

Check in this order:

```bash
# On IDS
sudo tail -n 20 /var/log/suricata/eve.json
sudo systemctl status wazuh-agent --no-pager
sudo tail -n 100 /var/ossec/logs/ossec.log

# On Wazuh server
sudo systemctl status wazuh-manager --no-pager
sudo tail -n 100 /var/ossec/logs/ossec.log
sudo /var/ossec/bin/agent_control -lc
```

If `eve.json` contains the alert but Wazuh does not show it, inspect the localfile XML and Wazuh agent log. If `eve.json` has no alert, troubleshoot Suricata and Traffic Mirroring first.
