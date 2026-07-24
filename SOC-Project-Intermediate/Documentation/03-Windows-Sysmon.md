# 03 — Windows Endpoint, Wazuh Agent and Sysmon

## 1. Connect using RDP

1. In EC2, select the Windows instance.
2. Choose **Connect** → **RDP client**.
3. Retrieve the administrator password with the `.pem` key.
4. Open the downloaded RDP file.
5. Confirm the server identity before entering credentials.

## 2. Test Wazuh connectivity

Open PowerShell as Administrator:

```powershell
Test-NetConnection -ComputerName WAZUH_PRIVATE_IP -Port 1514
Test-NetConnection -ComputerName WAZUH_PRIVATE_IP -Port 1515
```

Both tests should show `TcpTestSucceeded : True`.

## 3. Deploy the Wazuh agent

The safest beginner workflow is to generate the exact command from:

**Wazuh Dashboard → Agents management → Summary → Deploy new agent**

Use the Wazuh server **private IP**.

A version-pinned example is included in:

```text
Scripts/install-wazuh-agent-windows.ps1
```

After installation:

```powershell
Start-Service wazuhsvc
Get-Service wazuhsvc
```

Log file:

```text
C:\Program Files (x86)\ossec-agent\ossec.log
```

## 4. Install Sysmon

Download Sysmon only from Microsoft Sysinternals.

Copy your Sysmon configuration to:

```text
C:\SOC-Lab\sysmon-config.xml
```

Install:

```powershell
.\Sysmon64.exe -accepteula -i C:\SOC-Lab\sysmon-config.xml
```

Confirm:

```powershell
Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

## 5. Configure Wazuh to collect Sysmon

Open as Administrator:

```text
C:\Program Files (x86)\ossec-agent\ossec.conf
```

Add inside `<ossec_config>`:

```xml
<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

Also collect Windows Defender events:

```xml
<localfile>
  <location>Microsoft-Windows-Windows Defender/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

Restart:

```powershell
Restart-Service wazuhsvc
```

## 6. Verify events

Run a benign test command:

```powershell
powershell.exe -NoProfile -Command "Write-Output 'SOC-LAB-TEST'"
```

In Event Viewer:

```text
Applications and Services Logs
└── Microsoft
    └── Windows
        └── Sysmon
            └── Operational
```

Look for a process-creation event.

In Wazuh:

1. Open the Windows agent.
2. Select **Security events**.
3. Set time range to **Last 15 minutes**.
4. Search for:
   - `Sysmon`
   - `powershell.exe`
   - `SOC-LAB-TEST`

## Common errors

### Wazuh agent remains disconnected

```powershell
Get-Service wazuhsvc
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 100
Test-NetConnection WAZUH_PRIVATE_IP -Port 1514
```

Confirm that `ossec.conf` contains the correct private IP.

### Sysmon log channel does not exist

```powershell
Get-Service Sysmon64
wevtutil el | Select-String Sysmon
```

Reinstall with the Microsoft Sysmon executable and a valid XML configuration.

### XML configuration error

```powershell
.\Sysmon64.exe -s
.\Sysmon64.exe -c C:\SOC-Lab\sysmon-config.xml
```

Use the schema version reported by the installed Sysmon release.
