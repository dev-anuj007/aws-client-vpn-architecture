# AWS Client VPN Enterprise Reference Architecture

[![Deploy Documentation](https://github.com/dev-anuj007/aws-client-vpn-architecture/actions/workflows/deploy-docs.yml/badge.svg)](https://github.com/dev-anuj007/aws-client-vpn-architecture/actions/workflows/deploy-docs.yml)
[![Documentation](https://img.shields.io/badge/Docs-GitHub%20Pages-blue?logo=github)](https://dev-anuj007.github.io/aws-client-vpn-architecture/)
[![AWS](https://img.shields.io/badge/AWS-Client%20VPN%20%7C%20VPC-FF9900?logo=amazon-aws)](https://aws.amazon.com/vpn/client-vpn-download/)
[![Protocol](https://img.shields.io/badge/Protocol-OpenVPN%20%2F%20TLS-ea6100)](https://openvpn.net/)
[![Security](https://img.shields.io/badge/Security-Zero%20Trust%20%7C%20SAML%202.0-28a745)](#security--zero-trust-posture)
[![Package Manager](https://img.shields.io/badge/Package%20Manager-uv-blueviolet)](https://github.com/astral-sh/uv)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An enterprise-grade reference architecture, implementation blueprint, and operational guide for building scalable, high-availability, Zero-Trust remote access on Amazon Web Services using **AWS Client VPN**.

---

## 🏛️ Architecture Overview

![AWS Client VPN Architecture](docs/assets/cvpn-architecture.png)

AWS Client VPN is a managed client-based VPN service that enables secure remote access to AWS workloads and on-premises hybrid networks. It eliminates traditional bastion jump hosts and unmanaged EC2 VPN concentrators by offloading termination, high availability, and scaling directly to AWS managed infrastructure.

### The Problem: Legacy Remote Ingress Anti-Patterns
In legacy cloud environments, remote engineer access frequently suffers from critical architectural flaws:
* **Bastion Jump Hosts**: Publicly exposed SSH (port 22) or RDP (port 3389) endpoints create massive attack surfaces, prone to credential stuffing, brute force, and zero-day exploits.
* **Broad Network Exposure**: Once an engineer connects through a single-gateway appliance, they often receive unrestricted lateral movement within the entire private subnet.
* **Brittle Certificate Lifecycles**: Static certificates stored on developer workstations without automated revocation workflows (CRL) or Identity Provider (IdP) integration.
* **High Operational Overhead**: Self-hosted VPN servers (e.g. OpenVPN Access Server on EC2) require manual patching, single-point-of-failure clustering, and throughput management.

### The Solution: AWS Client VPN Zero-Trust Blueprint
This reference architecture provides:
1. **Zero-Trust Identity Ingress**: Enforce Single Sign-On (SSO) with Multi-Factor Authentication (MFA) via SAML 2.0 (Okta, Microsoft Entra ID / Azure AD, AWS IAM Identity Center).
2. **Granular, Group-Based Authorization**: Restrict engineers to specific destination CIDRs based on Directory Groups (e.g. Database Engineers reach `/32` RDS instances; Frontend devs access only dev clusters).
3. **Multi-AZ High Availability**: Active-active subnet associations across distinct Availability Zones ensuring automated failover with no manual intervention.
4. **Split-Tunnel Routing Optimization**: Direct corporate internal traffic over the encrypted tunnel while enabling non-sensitive internet traffic to route directly via client ISPs, preventing corporate bandwidth bottlenecks.
5. **End-to-End Observability**: Centralized CloudWatch Connection Logging, Metric Alarms (`ActiveConnections`, `BytesIn`, `BytesOut`), and VPC Flow Log correlation.

---

## 📂 Repository Structure

```ascii
aws-client-vpn-architecture/
├── .github/
│   └── workflows/
│       ├── deploy-docs.yml      # Automated GitHub Pages CI/CD deployment
│       └── ci.yml               # Strict MkDocs build & validation checks
├── docs/                        # Complete technical documentation suite
│   ├── assets/                  # Architecture diagrams, packet flows, SVG schemas
│   ├── aws-vpc.md               # VPC design, CIDR planning, and isolated tiers
│   ├── subnet.md                # Subnet association & IP exhaustion mitigation
│   ├── aws-route-tbl.md         # Route tables, gateway associations & propagation
│   ├── aws-sg.md                # Stateful security group chaining & rules
│   ├── eni.md                   # Managed Client VPN ENI lifecycle & SNAT behavior
│   ├── osi-model.md             # Applied OSI Model: Layer 3 TUN vs Layer 2 TAP
│   ├── aws-cvpn.md              # Client VPN service components & endpoints
│   ├── cvpn-working-mechanism.md# Detailed packet flow lifecycle & sequence flow
│   ├── cvpn-auth.md             # SAML 2.0, mTLS, and network authorization rules
│   ├── cvpn-use-case.md         # 5 Production Enterprise Architecture Scenarios
│   ├── cvpn-security.md         # Defense-in-depth, CRL revocation & IAM ABAC
│   ├── cvpn-monitoring.md       # CloudWatch metrics, connection logs & alarms
│   ├── faq.md                   # Enterprise architectural & interview FAQ
│   ├── reference.md             # Curated AWS RFCs, whitepapers & standards
│   └── index.md                 # Executive summary & architectural motivation
├── terraform/                   # Production-ready IaC reference implementation
│   ├── main.tf                  # VPC, subnets, Client VPN endpoint, associations
│   ├── variables.tf             # Configurable CIDRs, ports, and auth parameters
│   └── outputs.tf               # Endpoint IDs, DNS names, and configuration guides
├── mkdocs.yml                   # Material for MkDocs enterprise configuration
├── pyproject.toml               # Project dependencies managed via UV
├── uv.lock                      # Deterministic locked dependency graph
├── LICENSE                      # MIT Open Source License
└── README.md                    # Repository documentation portal
```

---

## ⚡ Quickstart & Local Documentation Server

This project utilizes [uv](https://github.com/astral-sh/uv), the ultra-fast Python package and project manager.

### Prerequisites
* Python 3.11+
* `uv` package manager (`curl -LsSf https://astral.sh/uv/install.sh | sh` or `winget install astral-sh.uv`)

### 1. Clone the Repository
```bash
git clone https://github.com/dev-anuj007/aws-client-vpn-architecture.git
cd aws-client-vpn-architecture
```

### 2. Synchronize Dependencies
```bash
uv sync
```

### 3. Launch the Local Documentation Server
```bash
uv run mkdocs serve -a 127.0.0.1:8080
```
Open **[http://127.0.0.1:8080](http://127.0.0.1:8080)** in your browser to explore the interactive architecture portal with dark mode, search, and dynamic diagrams.

---

## 🚀 Automated GitHub Pages Deployment

The repository includes a production-ready GitHub Actions workflow (`.github/workflows/deploy-docs.yml`) that automatically compiles and deploys the documentation site to **GitHub Pages** whenever changes are pushed to `master`.

To enable GitHub Pages in your fork:
1. Navigate to **Settings** > **Pages** in your GitHub repository.
2. Under **Build and deployment** > **Source**, choose **GitHub Actions**.
3. Push to `master`, and your site will be live at `https://<username>.github.io/aws-client-vpn-architecture/`.

---

## 🛡️ Key Architectural Pillars

| Pillar | Implementation Highlights |
| :--- | :--- |
| **Authentication** | SAML 2.0 federated authentication (Okta / Entra ID / IAM Identity Center) or Mutual TLS (mTLS) backed by AWS Certificate Manager (ACM). |
| **Authorization** | Strict network-based ingress rules mapping Active Directory / IdP groups to specific CIDRs and port ranges. |
| **High Availability** | Associated with minimum 2 target subnets across distinct Availability Zones (e.g., `us-east-1a` and `us-east-1b`). |
| **Traffic Isolation** | Source Network Address Translation (SNAT) applied automatically at the managed Subnet ENI layer. |
| **Observability** | Connection logging to Amazon CloudWatch Logs; proactive alerting on `ActiveConnections` and error states. |

---

## 🤝 Contributing

Contributions, architectural discussions, and enhancements are welcome! Please open an issue or submit a pull request following standard Git branching workflows.

## 📄 License

This reference architecture is open-source under the [MIT License](LICENSE).