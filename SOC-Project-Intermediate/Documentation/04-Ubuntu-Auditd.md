# 04 — Ubuntu Endpoint, Wazuh Agent and Auditd

## 1. Connect

```bash
ssh -i soc-lab-key.pem ubuntu@UBUNTU_PUBLIC_IP
```

## 2. Install prerequisites and Auditd

```bash
sudo apt update
sudo apt install -y curl gnupg apt-transport-https auditd audispd-plugins
sudo systemctl enable --now auditd
sudo systemctl status auditd --no-pager
```

## 3. Install the Wazuh agent

Use the helper:

```bash
sudo WAZUH_MANAGER_IP="WAZUH_PRIVATE_IP" \
  bash Scripts/install-wazuh-agent-ubuntu.sh
```

When running directly on EC2, copy the script to the endpoint first.

Manual validation:

```bash
sudo systemctl status wazuh-agent --no-pager
sudo tail -n 100 /var/ossec/logs/ossec.log
```

## 4. Configure Auditd collection

Edit:

```bash
sudo nano /var/ossec/etc/ossec.conf
```

Add before `</ossec_config>`:

```xml
<localfile>
  <log_format>audit</log_format>
  <location>/var/log/audit/audit.log</location>
</localfile>
```

## 5. Configure a safe FIM folder

Create:

```bash
sudo mkdir -p /opt/soc-lab-monitored
sudo chown ubuntu:ubuntu /opt/soc-lab-monitored
```

Add to the agent `ossec.conf` inside the existing `<syscheck>` block:

```xml
<directories realtime="yes" check_all="yes">/opt/soc-lab-monitored</directories>
```

Restart:

```bash
sudo systemctl restart wazuh-agent
```

## 6. Add simple Auditd rules

Copy:

```text
Scripts/soc-lab-audit.rules
```

to:

```text
/etc/audit/rules.d/soc-lab.rules
```

Load:

```bash
sudo augenrules --load
sudo auditctl -l
```

## 7. Generate safe events

```bash
echo "created" > /opt/soc-lab-monitored/alert-test.txt
echo "modified" >> /opt/soc-lab-monitored/alert-test.txt
chmod 600 /opt/soc-lab-monitored/alert-test.txt
rm /opt/soc-lab-monitored/alert-test.txt
```

Generate a sudo event:

```bash
sudo -k
sudo id
```

## 8. Verify in Wazuh

Search for:

- `syscheck`
- `/opt/soc-lab-monitored`
- `audit`
- `sudo`
- the Ubuntu agent name

## Common errors

### `auditd` cannot be restarted manually

Some Ubuntu releases protect Auditd from a normal restart. Use:

```bash
sudo augenrules --load
sudo service auditd restart
```

### `eve.json` or Auditd log permission issue

The Wazuh agent normally runs with sufficient privileges. Confirm the file exists:

```bash
sudo ls -l /var/log/audit/audit.log
sudo tail -n 20 /var/log/audit/audit.log
```

### Agent uses the wrong manager address

```bash
sudo grep -n "<address>" /var/ossec/etc/ossec.conf
sudo sed -i 's/OLD_IP/NEW_PRIVATE_IP/' /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
```
