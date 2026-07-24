# 01 — AWS Infrastructure Setup

## Objective

Create a beginner-friendly AWS network and five EC2 systems:

- Wazuh server
- Windows endpoint
- Ubuntu endpoint
- Kali simulation host
- Ubuntu Suricata IDS sensor

Use one AWS Region for all resources. The screenshots in this project use `us-east-1`.

## 1. Create an AWS budget first

1. Open **Billing and Cost Management**.
2. Choose **Budgets** → **Create budget**.
3. Select **Cost budget**.
4. Set a small monthly amount suitable for your lab.
5. Add your email address for alerts.
6. Create an additional alert near 80% of the budget.

A budget does not automatically stop resources. Follow the shutdown guide when the lab is not in use.

## 2. Create a key pair

1. Open **EC2**.
2. In the left menu, choose **Key Pairs**.
3. Select **Create key pair**.
4. Name: `soc-lab-key`.
5. Type: `RSA`.
6. Private key format:
   - `.pem` for OpenSSH, Windows Terminal or MobaXterm.
   - `.ppk` only when using older PuTTY workflows.
7. Download and protect the private key.

Never upload the private key to GitHub.

## 3. Create the VPC

1. Open **VPC**.
2. Choose **Your VPCs** → **Create VPC**.
3. Select **VPC only**.
4. Name: `SOC-LAB-VPC`.
5. IPv4 CIDR: `10.0.0.0/16`.
6. Tenancy: `Default`.
7. Create the VPC.

## 4. Create a public subnet

1. Open **Subnets** → **Create subnet**.
2. VPC: `SOC-LAB-VPC`.
3. Name: `SOC-PUBLIC-SUBNET`.
4. Availability Zone: choose one supported by your Region.
5. IPv4 CIDR: `10.0.1.0/24`.
6. Create the subnet.
7. Select the subnet → **Actions** → **Edit subnet settings**.
8. Enable **Auto-assign public IPv4 address** for this temporary lab.

## 5. Create and attach the Internet Gateway

1. Open **Internet gateways**.
2. Choose **Create internet gateway**.
3. Name: `SOC-LAB-IGW`.
4. Create it.
5. Select it → **Actions** → **Attach to a VPC**.
6. Choose `SOC-LAB-VPC`.

## 6. Create a public route table

1. Open **Route tables** → **Create route table**.
2. Name: `SOC-PUBLIC-RT`.
3. VPC: `SOC-LAB-VPC`.
4. Create it.
5. Open **Routes** → **Edit routes**.
6. Add:
   - Destination: `0.0.0.0/0`
   - Target: `SOC-LAB-IGW`
7. Save.
8. Open **Subnet associations** → **Edit subnet associations**.
9. Select `SOC-PUBLIC-SUBNET`.

## 7. Create security groups

### Wazuh server security group

Name: `SG-WAZUH-SERVER`

| Protocol | Port | Source | Purpose |
|---|---:|---|---|
| TCP | 22 | Your public IP `/32` | SSH administration |
| TCP | 443 | Your public IP `/32` | Wazuh dashboard |
| TCP | 1514 | Endpoint security groups | Agent events |
| TCP | 1515 | Endpoint security groups | Agent enrollment |
| TCP | 55000 | Do not expose publicly | API, only when specifically required |

### Windows endpoint security group

Name: `SG-WINDOWS-ENDPOINT`

| Protocol | Port | Source |
|---|---:|---|
| TCP | 3389 | Your public IP `/32` |
| ICMP | Echo request | `SG-KALI-LAB` only when needed |

### Ubuntu endpoint security group

Name: `SG-UBUNTU-ENDPOINT`

| Protocol | Port | Source |
|---|---:|---|
| TCP | 22 | Your public IP `/32` |
| TCP | 8080 | `SG-KALI-LAB` for the benign IDS test |

### Kali lab security group

Name: `SG-KALI-LAB`

| Protocol | Port | Source |
|---|---:|---|
| TCP | 22 | Your public IP `/32` |

### IDS sensor security group

Name: `SG-SURICATA-IDS`

| Protocol | Port | Source |
|---|---:|---|
| TCP | 22 | Your public IP `/32` |
| UDP | 4789 | `10.0.1.0/24` or the source endpoint SG | VXLAN mirrored traffic |

## 8. Launch instances

Use Ubuntu 24.04 LTS or 22.04 LTS for Linux systems.

| Name | Suggested type | Storage | Notes |
|---|---|---:|---|
| `WAZUH-SERVER` | `t3.large` | 50–80 GB gp3 | 8 GB RAM recommended for all-in-one |
| `WINDOWS-ENDPOINT` | `t3.medium` | 40 GB | Windows Server 2022 |
| `UBUNTU-ENDPOINT` | `t3.small` | 20 GB | Auditd and Wazuh agent |
| `KALI-LAB` | `t3.small` | 20 GB | Marketplace AMI or Ubuntu with basic test tools |
| `SURICATA-IDS` | `t3.medium` | 30 GB | IDS sensor and Wazuh agent |

For every instance:

1. Choose `SOC-LAB-VPC`.
2. Choose `SOC-PUBLIC-SUBNET`.
3. Select the correct security group.
4. Select `soc-lab-key`.
5. Enable termination protection for the Wazuh server if desired.
6. Add tags such as `Project=SOC-Lab`.

## 9. Record private IP addresses

Use private IP addresses for all internal communications.

Create a table in your notes:

| Host | Private IP |
|---|---|
| Wazuh server | `10.0.1.x` |
| Windows endpoint | `10.0.1.x` |
| Ubuntu endpoint | `10.0.1.x` |
| Kali lab | `10.0.1.x` |
| Suricata IDS | `10.0.1.x` |

Do not hard-code public IP addresses in agent configurations because they may change after stop/start.

## Validation checklist

- All instances are in the same VPC.
- All instances have passed EC2 status checks.
- The route table contains `0.0.0.0/0 → Internet Gateway`.
- SSH and RDP are limited to your public IP.
- Wazuh agent ports are not open to the whole internet.
- IDS security group allows UDP 4789 from mirror sources.
