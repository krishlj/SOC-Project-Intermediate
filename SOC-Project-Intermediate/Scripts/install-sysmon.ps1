# Run in an elevated PowerShell window.
# Download Sysmon separately from Microsoft Sysinternals and place Sysmon64.exe
# in the same directory as this script.

param(
    [string]$SysmonExe = ".\Sysmon64.exe",
    [string]$ConfigPath = ".\sysmon-config.xml"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $SysmonExe)) {
    throw "Sysmon executable not found: $SysmonExe"
}
if (-not (Test-Path $ConfigPath)) {
    throw "Sysmon configuration not found: $ConfigPath"
}

& $SysmonExe -accepteula -i $ConfigPath

if ($LASTEXITCODE -ne 0) {
    throw "Sysmon installation returned exit code $LASTEXITCODE"
}

Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
