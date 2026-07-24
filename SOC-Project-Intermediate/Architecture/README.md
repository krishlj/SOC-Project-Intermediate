# Architecture notes

## Logical layout

```text
Internet
   |
Internet Gateway
   |
Public route table
   |
SOC VPC 10.0.0.0/16
   |
Public lab subnet 10.0.1.0/24
   |
+----------------+----------------+----------------+----------------+----------------+
| Wazuh server   | Windows EC2    | Ubuntu EC2     | Kali EC2       | Suricata IDS  |
| SIEM/XDR       | Sysmon         | Auditd         | Lab simulator  | NIDS           |
+----------------+----------------+----------------+----------------+----------------+
```

## Production improvement

The single public subnet is acceptable for a temporary learning lab, but a production-style design should place monitored endpoints and the IDS sensor in private subnets. Administration should use AWS Systems Manager Session Manager, a bastion host, or a VPN.

## Data flows

1. Wazuh agents send endpoint telemetry to the Wazuh manager over the private VPC network.
2. Selected endpoint ENI traffic is mirrored to the IDS target.
3. AWS encapsulates mirrored traffic with VXLAN and sends it to UDP port 4789 on the target.
4. Suricata writes alerts to `/var/log/suricata/eve.json`.
5. The Wazuh agent on the IDS sensor reads `eve.json` and forwards events to the Wazuh server.
6. Wazuh decodes, matches rules, indexes and displays the alert.
