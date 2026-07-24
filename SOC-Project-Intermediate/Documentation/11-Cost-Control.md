# 11 — AWS Cost Control and Shutdown

## Stop the lab after practice

In EC2:

1. Select Windows, Ubuntu, Kali and IDS instances.
2. Choose **Instance state** → **Stop instance**.
3. Stop the Wazuh server last.
4. Confirm the state is `Stopped`.

Stopped EC2 instances do not incur compute charges, but EBS volumes, snapshots, Elastic IP addresses and some networking services can still cost money.

## Resources to review

- EC2 instances
- EBS volumes and snapshots
- Elastic IP addresses
- NAT Gateways
- Network Load Balancers
- VPC Traffic Mirroring usage
- CloudWatch Logs
- Data transfer
- AWS Marketplace subscriptions

## Resume order

1. Start the Wazuh server.
2. Wait for status checks.
3. Confirm Wazuh services.
4. Start the IDS sensor.
5. Start Windows and Ubuntu endpoints.
6. Start Kali only when performing an approved test.
7. Confirm all agent private IP configurations still match.

Private IPs normally remain the same after stop/start when the primary ENI remains attached. Public IPs may change unless an Elastic IP is used.

## Remove the lab completely

Delete in this order:

1. Traffic mirror sessions.
2. Traffic mirror filters and targets.
3. EC2 instances.
4. EBS volumes not deleted with instances.
5. Elastic IP addresses.
6. Security groups.
7. Route table associations.
8. Internet Gateway attachment.
9. Subnet.
10. VPC.

Check the Billing dashboard afterward.
