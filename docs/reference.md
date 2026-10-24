# References & Industry Standards

An authoritative catalog of official cloud specifications, security standards, and open-source tooling supporting this reference architecture.

---

## Official AWS Technical Documentation

* [AWS Client VPN User Guide & Administration](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html)
* [Amazon Virtual Private Cloud (VPC) User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
* [AWS Client VPN SAML 2.0 Integration with Microsoft Entra ID](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/client-authentication-saml.html)
* [AWS Certificate Manager (ACM) Documentation](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
* [Amazon CloudWatch Logs Insights Query Syntax](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)

---

## Networking RFCs & Industry Protocols

* **[RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918)**: Address Allocation for Private Internets (IPv4 private address spaces `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`).
* **[RFC 6598](https://datatracker.ietf.org/doc/html/rfc6598)**: IANA-Reserved IPv4 Prefix for Shared Address Space / Carrier-Grade NAT (`100.64.0.0/10`).
* **[RFC 5246](https://datatracker.ietf.org/doc/html/rfc5246)**: The Transport Layer Security (TLS) Protocol Version 1.2.
* **[RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)**: The Transport Layer Security (TLS) Protocol Version 1.3.
* **[OpenVPN Cryptographic Layer Protocol Specification](https://openvpn.net/community-resources/openvpn-cryptographic-layer/)**: Framing, HMAC signature packet verification, and key exchange mechanics.

---

## Compliance & Security Frameworks

* **[AWS Well-Architected Framework: Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/welcome.html)**: Principles of least privilege, Defense-in-Depth, and identity perimeter security.
* **[AWS Well-Architected Framework: Reliability Pillar](https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/welcome.html)**: Multi-AZ elasticity and disaster recovery design.
* **[CIS AWS Foundations Benchmark v3.0](https://www.cisecurity.org/benchmark/amazon_web_services)**: Recommendations for IAM, logging, VPC Flow Logs, and cryptographic controls.
* **[NIST SP 800-207](https://csrc.nist.gov/publications/detail/sp/800-207/final)**: Zero Trust Architecture principles and enterprise deployment strategies.

---

## Infrastructure as Code & Tooling

* [Terraform AWS Provider: `aws_ec2_client_vpn_endpoint`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint)
* [AWS CloudFormation: `AWS::EC2::ClientVpnEndpoint`](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-clientvpnendpoint.html)
* [Easy-RSA Open-Source CA Management Utility](https://github.com/OpenVPN/easy-rsa)
* [Official AWS Client VPN Desktop Application](https://aws.amazon.com/vpn/client-vpn-download/)
