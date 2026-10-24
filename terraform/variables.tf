variable "environment" {
  type        = string
  description = "Target deployment environment (e.g. dev, staging, prod)"
  default     = "prod"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the target VPC where subnets will be associated"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the target VPC (e.g. 10.0.0.0/16)"
}

variable "associated_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs in distinct Availability Zones for multi-AZ resilience"
}

variable "client_cidr_block" {
  type        = string
  description = "Non-overlapping IPv4 CIDR block from which to lease client IP addresses (must be /22 to /12)"
  default     = "172.16.0.0/16"
}

variable "server_certificate_arn" {
  type        = string
  description = "The ARN of the ACM server certificate for TLS termination"
}

variable "authentication_type" {
  type        = string
  description = "Authentication type: certificate-authentication, directory-service-authentication, or federated-authentication"
  default     = "certificate-authentication"
}

variable "client_certificate_arn" {
  type        = string
  description = "The ARN of the client root certificate in ACM (required if authentication_type is certificate-authentication)"
  default     = null
}

variable "saml_provider_arn" {
  type        = string
  description = "The ARN of the IAM SAML Identity Provider (required if authentication_type is federated-authentication)"
  default     = null
}

variable "split_tunnel" {
  type        = bool
  description = "Whether split-tunneling is enabled (true directs only corporate CIDRs through VPN)"
  default     = true
}

variable "transport_protocol" {
  type        = string
  description = "Transport protocol: udp (recommended) or tcp"
  default     = "udp"
}

variable "vpn_port" {
  type        = number
  description = "The port number for the VPN connection (443 or 1194)"
  default     = 1194
}

variable "session_timeout_hours" {
  type        = number
  description = "Maximum session timeout duration in hours (8, 10, 12, or 24)"
  default     = 10
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers to push to clients (e.g. VPC base IP + 2 for Route 53 private resolution)"
  default     = []
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention period in days for connection logs"
  default     = 90
}
