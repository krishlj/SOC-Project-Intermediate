# 06 — AWS VPC Traffic Mirroring

## Objective

Copy selected traffic from an EC2 network interface to the Suricata sensor ENI.

## Prerequisites

- Source and target are in the same AWS Region.
- The source instance type supports Traffic Mirroring.
- The IDS target security group allows UDP `4789` from the mirror source.
- You know the ENI IDs of the source and IDS instances.
- Suricata is installed and running.

## 1. Find the ENIs

1. Open **EC2** → **Instances**.
2. Select the Ubuntu or Windows source.
3. Open **Networking**.
4. Record the primary network interface ID.
5. Repeat for the Suricata IDS instance.

## 2. Create the mirror target

1. Open **VPC**.
2. In the left navigation, select **Traffic Mirroring** → **Mirror targets**.
3. Choose **Create traffic mirror target**.
4. Name: `SOC-SURICATA-TARGET`.
5. Target type: **Network Interface**.
6. Select the Suricata IDS ENI.
7. Create.

## 3. Create the mirror filter

1. Select **Mirror filters** → **Create traffic mirror filter**.
2. Name: `SOC-LAB-FILTER`.
3. Create the filter.
4. Add inbound and outbound rules.

Begin with a narrow test filter:

| Direction | Rule number | Action | Protocol | Source | Destination |
|---|---:|---|---|---|---|
| Inbound | 100 | Accept | TCP | `10.0.0.0/16` | `10.0.0.0/16` |
| Outbound | 100 | Accept | TCP | `10.0.0.0/16` | `10.0.0.0/16` |

Add other protocols only when required. Narrow filters reduce noise and cost.

## 4. Create the mirror session

1. Select **Mirror sessions** → **Create traffic mirror session**.
2. Name: `UBUNTU-TO-SURICATA`.
3. Mirror source: Ubuntu endpoint ENI.
4. Mirror target: `SOC-SURICATA-TARGET`.
5. Mirror filter: `SOC-LAB-FILTER`.
6. Session number: `1`.
7. VNI: allow AWS to choose or use a documented lab value.
8. Packet length: leave empty for full packets in a small lab.
9. Create.

Create a separate session for each additional endpoint you want to mirror.

## 5. Validate arrival

On the IDS sensor:

```bash
sudo tcpdump -ni any udp port 4789
```

Generate a benign HTTP connection from Kali to the mirrored Ubuntu endpoint. VXLAN traffic should appear.

## 6. Validate Suricata

```bash
sudo tail -f /var/log/suricata/eve.json | jq .
```

## Troubleshooting

### Mirror session creation is unavailable

The source instance type may not support Traffic Mirroring. Check the current AWS supported-instance documentation and change the source instance type if needed.

### Target receives no traffic

Verify:

1. Correct source ENI.
2. Correct target ENI.
3. Filter contains matching inbound or outbound accept rules.
4. IDS security group permits UDP 4789.
5. Source and target can route to each other.
6. The test connection actually crosses the mirrored source ENI.
