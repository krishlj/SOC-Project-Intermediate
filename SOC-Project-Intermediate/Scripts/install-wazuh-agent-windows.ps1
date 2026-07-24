# Run in an elevated PowerShell window.
# Verify the current Wazuh package version before use.
# The manager must be the same version or newer than the agent.

param(
    [Parameter(Mandatory = $true)]
    [string]$ManagerIp,

    [string]$AgentName = $env:COMPUTERNAME,

    [string]$Version = "4.14.6"
)

$ErrorActionPreference = "Stop"
$MsiName = "wazuh-agent-$Version-1.msi"
$DownloadUrl = "https://packages.wazuh.com/4.x/windows/$MsiName"
$Destination = Join-Path $env:TEMP $MsiName

Write-Host "Testing enrollment connectivity..."
Test-NetConnection -ComputerName $ManagerIp -Port 1515 | Format-List

Write-Host "Downloading Wazuh agent from the official package repository..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $Destination

Write-Host "Installing Wazuh agent..."
$Arguments = @(
    "/i", "`"$Destination`"",
    "/q",
    "WAZUH_MANAGER=`"$ManagerIp`"",
    "WAZUH_REGISTRATION_SERVER=`"$ManagerIp`"",
    "WAZUH_AGENT_NAME=`"$AgentName`""
)
$Process = Start-Process msiexec.exe -ArgumentList $Arguments -Wait -PassThru

if ($Process.ExitCode -ne 0) {
    throw "MSI installation failed with exit code $($Process.ExitCode)"
}

Start-Service wazuhsvc
Get-Service wazuhsvc
Write-Host "Agent log: C:\Program Files (x86)\ossec-agent\ossec.log"
