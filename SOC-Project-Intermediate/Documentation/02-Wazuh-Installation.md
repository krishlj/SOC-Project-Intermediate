# 02 — Wazuh All-in-One Installation

## Supported approach

This guide uses the official Wazuh installation assistant on one Ubuntu EC2 instance. The server hosts the Wazuh indexer, manager and dashboard.

## 1. Connect to the server

```bash
chmod 400 soc-lab-key.pem
ssh -i soc-lab-key.pem ubuntu@WAZUH_PUBLIC_IP
```

## 2. Confirm system resources

```bash
uname -m
lsb_release -a
free -h
df -h
```

Recommended for this lab:

- 64-bit operating system.
- At least 8 GB RAM for an all-in-one lab.
- At least 50 GB free storage.
- Root or sudo privileges.

## 3. Update Ubuntu

```bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo apt install -y curl unzip tar gnupg apt-transport-https
sudo reboot
```

Reconnect after the reboot.

## 4. Run the Wazuh installation assistant

The script below uses the Wazuh 4.14 installation path current when this repository was prepared.

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

Wait for the final success message. Save the displayed username and password securely.

## 5. Retrieve credentials later

The installer normally creates `wazuh-install-files.tar`.

```bash
sudo tar -axf wazuh-install-files.tar \
  wazuh-install-files/wazuh-passwords.txt -O
```

Do not publish this output.

## 6. Confirm services

```bash
sudo systemctl status wazuh-manager --no-pager
sudo systemctl status wazuh-indexer --no-pager
sudo systemctl status wazuh-dashboard --no-pager
sudo systemctl status filebeat --no-pager
```

Check ports:

```bash
sudo ss -lntp | grep -E ':(443|1514|1515|55000)\b'
```

## 7. Open the dashboard

From your computer:

```text
https://WAZUH_PUBLIC_IP
```

A self-signed certificate warning is expected in a temporary lab. Continue only after confirming the IP belongs to your Wazuh instance.

## 8. Basic hardening

1. Restrict dashboard port `443` to your public IP.
2. Keep API port `55000` private.
3. Use the Wazuh private IP for all agents.
4. Change default passwords.
5. Take an EBS snapshot after the configuration is stable.
6. Do not store credentials in screenshots or repository files.

## Installation failure checks

### Script stops because of low resources

Check:

```bash
free -h
df -h
```

Stop the instance, change to a larger type, and expand the EBS volume if necessary.

### Package manager is locked

```bash
ps aux | grep -E 'apt|dpkg'
sudo dpkg --configure -a
sudo apt --fix-broken install
sudo apt update
```

Do not delete lock files while a package process is running.

### Dashboard service is running but page does not open

1. Confirm the instance public IP.
2. Confirm inbound TCP 443 from your public IP.
3. Check:

```bash
sudo systemctl status wazuh-dashboard
sudo journalctl -u wazuh-dashboard -n 100 --no-pager
sudo ss -lntp | grep ':443'
```

### Agent ports are not listening

```bash
sudo systemctl restart wazuh-manager
sudo journalctl -u wazuh-manager -n 100 --no-pager
sudo ss -lntp | grep -E ':(1514|1515)\b'
```
