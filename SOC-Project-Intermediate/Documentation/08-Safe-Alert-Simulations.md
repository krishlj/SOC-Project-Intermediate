# 08 — Safe Alert Simulations

## Safety rules

- Use only your own private AWS lab IP addresses.
- Do not target public websites, random public IPs or third-party networks.
- Use dedicated test accounts and temporary files.
- Stop immediately if the target is not the system you intended.
- These tests are non-destructive and do not install malware.

## Scenario 1 — Windows failed-login events

1. Create a dedicated local test user on the Windows endpoint:

```powershell
$Password = Read-Host "Enter a temporary lab password" -AsSecureString
New-LocalUser -Name "soclabtest" -Password $Password
```

2. Lock the current credential cache:

```powershell
runas /user:.\soclabtest cmd.exe
```

3. Enter an incorrect password only two or three times.
4. Search Wazuh for Windows Event ID `4625`.
5. Remove the test user after the demonstration:

```powershell
Remove-LocalUser -Name "soclabtest"
```

Do not perform repeated automated attempts.

## Scenario 2 — Benign PowerShell process marker

Run:

```powershell
powershell.exe -NoProfile -Command "Write-Output 'SOC-LAB-TEST'"
```

Search Wazuh for:

- `powershell.exe`
- `SOC-LAB-TEST`
- Sysmon process creation

## Scenario 3 — Ubuntu File Integrity Monitoring

```bash
echo "created" > /opt/soc-lab-monitored/alert-test.txt
echo "modified" >> /opt/soc-lab-monitored/alert-test.txt
chmod 600 /opt/soc-lab-monitored/alert-test.txt
rm /opt/soc-lab-monitored/alert-test.txt
```

Search for:

- `/opt/soc-lab-monitored/alert-test.txt`
- `syscheck`
- file added, modified, permissions changed and deleted

## Scenario 4 — Linux sudo and Auditd

```bash
sudo -k
sudo id
```

Search for:

- `sudo`
- `audit`
- `USER_CMD`
- Ubuntu agent name

## Scenario 5 — Limited private-network scan

From Kali, scan only the private IP of your own Ubuntu endpoint:

```bash
nmap -sT -Pn --top-ports 20 UBUNTU_PRIVATE_IP
```

This is a small connectivity and IDS test, not an exploitation attempt.

Stop if the IP is not part of your `10.0.0.0/16` lab network.

## Scenario 6 — Deterministic Suricata HTTP alert

### On the Ubuntu endpoint

```bash
mkdir -p ~/soc-http-test
cd ~/soc-http-test
python3 -m http.server 8080
```

### From Kali

```bash
curl -v http://UBUNTU_PRIVATE_IP:8080/SOC-LAB-TEST
```

The request may return `404`; that is acceptable. The URI is the detection marker.

### On the IDS sensor

```bash
sudo jq 'select(.event_type=="alert")' \
  /var/log/suricata/eve.json | tail -n 20
```

### In Wazuh

Search for:

```text
SOC LAB benign HTTP test
```

## Evidence checklist

For each scenario, capture:

- command or action used
- source and destination private IP
- Wazuh agent
- alert timestamp
- rule ID and level
- MITRE mapping, when present
- your analyst conclusion
- screenshot with sensitive data redacted
