# Frequently Asked Questions (FAQ)

An architectural and operational reference addressing common design decisions, performance tradeoffs, and security controls for AWS Client VPN.

---

???+ question "1. Why choose AWS Client VPN over self-managed OpenVPN Access Server on EC2?"

    While running OpenVPN Access Server on an EC2 instance may appear cheaper initially, it introduces significant hidden operational liabilities and security risks:

    * **High Availability & Failover**: An EC2 instance is a single point of failure. Setting up active/active clustering across Availability Zones with elastic IPs and state synchronization requires complex custom scripting and maintenance.
    * **Maintenance & Patching**: Operating system patches, OpenSSL zero-day vulnerability remediations, and Linux kernel updates must be maintained and audited manually.
    * **Throughput Bottlenecks**: Scaling an EC2 instance requires resizing instance types, which terminates active connections. AWS Client VPN elastically provisions capacity behind the scenes.
    * **Native AWS Integration**: AWS Client VPN integrates natively with AWS Certificate Manager, Amazon CloudWatch Logs, IAM SAML federation, and AWS Directory Service without third-party plugins.

---

???+ question "2. What is the business and cost impact of Split-Tunneling?"

    Enabling **Split-Tunneling** is a recommended cloud best practice for general engineering access:

    * **Bandwidth Cost Reduction**: Without split-tunneling (Full-Tunnel mode), high-bandwidth client traffic (Zoom video calls, YouTube, personal downloads) routes into AWS and egresses through AWS NAT Gateways, incurring substantial NAT data processing and internet egress fees ($0.045/GB + $0.09/GB).
    * **Latency Optimization**: Direct internet traffic exits through the user's home ISP connection, providing faster speeds and avoiding double-hop latency to AWS data centers.
    * **Battery & Performance**: Reduces local CPU encryption overhead on client laptops by only encrypting traffic bound for corporate IP subnets.

---

???+ question "3. Should we configure UDP port 1194 or TCP port 443?"

    **UDP port 1194 is strongly recommended for production workloads.**

    * **Preventing TCP-over-TCP Meltdown**: Running TCP inside TCP (such as web browsing or SSH over a TCP-based VPN tunnel) creates the TCP meltdown phenomenon: packet drops cause both inner and outer layers to initiate independent retransmissions and exponential backoffs, causing throughput to collapse.
    * **Fallback Profile**: TCP port 443 should only be provided as a secondary fallback profile for engineers connecting from restrictive hotel, airport, or client guest Wi-Fi networks that block outbound UDP traffic.

---

???+ question "4. How do connected clients resolve private internal domain names?"

    Configure the **DNS Servers** parameter on the Client VPN endpoint to point to the **Amazon-Provided DNS server** (`VPC Base IP + 2`, e.g. `10.0.0.2`).

    * When connected, the client's DNS queries for Route 53 Private Hosted Zones (e.g. `api.internal.mycorp` or `db.staging.aws`) are resolved privately through the VPC DNS resolver without leaking internal domain records to public DNS resolvers.
    * For split-tunnel configurations, public DNS queries continue resolving via the client's local DNS servers.

---

???+ question "5. Can a single Client VPN endpoint grant access to multiple VPCs?"

    **Yes.** While a Client VPN endpoint can only be associated with subnets in a **single VPC (the Ingress VPC)**, clients can reach workloads in any number of adjacent VPCs if you:

    1. Establish **VPC Peering** or connect the Ingress VPC to an **AWS Transit Gateway (TGW)**.
    2. Add routes in the **Client VPN Endpoint Route Table** targeting each destination VPC CIDR.
    3. Update the **VPC Route Table** of the associated subnet to forward traffic across the peering connection or Transit Gateway attachment.
    4. Add corresponding **Authorization Rules** granting the required groups permission to each destination CIDR.

---

???+ question "6. What happens if an entire AWS Availability Zone experiences an outage?"

    If your Client VPN endpoint is associated with target subnets across **two or more Availability Zones** (e.g., `us-east-1a` and `us-east-1b`), the service provides automated multi-AZ resilience:

    * The endpoint monitors the health of the underlying subnet network interfaces.
    * If `us-east-1a` degrades, traffic is automatically routed through the healthy network interface in `us-east-1b`.
    * New client connections are automatically assigned to the operational Availability Zone.

---

???+ question "7. Does AWS Client VPN support IPv6?"

    AWS Client VPN currently supports **IPv4 traffic only**:

    * The Client CIDR block must be an IPv4 range (between `/22` and `/12`).
    * Target network associations, routes, and authorization rules must be defined using IPv4 CIDR blocks.

---

???+ question "8. How is AWS Client VPN priced, and how can we optimize costs?"

    AWS Client VPN billing consists of two components:

    1. **Endpoint Association Fee**: Fixed hourly rate per associated subnet (~$0.10/hour per subnet association = ~$73/month per AZ association).
    2. **Client Connection Fee**: Hourly fee per active connected client session (~$0.05/hour per active connection).

    #### Cost Optimization Strategies:

    * **Consolidate Endpoints**: Instead of creating separate endpoints for Dev, QA, Staging, and Production, deploy a single shared endpoint and use **group-based Authorization Rules** to segment access.
    * **Multi-AZ Association Balance**: Associate 2 subnets for production workloads (high availability); single-AZ association may suffice for non-critical development sandbox environments.
    * **Enforce Idle Timeouts**: Configure session timeouts (e.g. 8–10 hours) so inactive connections do not run indefinitely overnight.

---

???+ question "9. How do we execute an emergency offboarding of an employee?"

    * **If using SAML 2.0 (SSO)**: Immediately disable or delete the user's account in your corporate Identity Provider (Okta / Microsoft Entra ID). Terminate active sessions via AWS CLI:
      ```bash
      aws ec2 terminate-client-vpn-connections \
          --client-vpn-endpoint-id cvpn-endpoint-xxxx \
          --connection-id cvpn-connection-xxxx
      ```
    * **If using Mutual TLS (mTLS)**: Generate a Certificate Revocation List (CRL) containing the client certificate's serial number, and import the CRL to the Client VPN endpoint.