terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group & Stream for Connection Logging
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "client_vpn" {
  name              = "/aws/client-vpn/${var.environment}-endpoint"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AWS-Client-VPN-Architecture"
  }
}

resource "aws_cloudwatch_log_stream" "client_vpn" {
  name           = "connection-logs"
  log_group_name = aws_cloudwatch_log_group.client_vpn.name
}

# ------------------------------------------------------------------------------
# Security Group for Client VPN Network Interfaces
# ------------------------------------------------------------------------------
resource "aws_security_group" "client_vpn" {
  name_prefix = "${var.environment}-client-vpn-sg-"
  description = "Security group attached to AWS Client VPN subnet associations"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic from VPN to internal workloads"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-client-vpn-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# AWS Client VPN Endpoint
# ------------------------------------------------------------------------------
resource "aws_ec2_client_vpn_endpoint" "main" {
  description            = "Enterprise Client VPN Endpoint - ${var.environment}"
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = var.split_tunnel
  transport_protocol     = var.transport_protocol
  vpn_port               = var.vpn_port
  session_timeout_hours  = var.session_timeout_hours
  dns_servers            = var.dns_servers
  security_group_ids     = [aws_security_group.client_vpn.id]
  vpc_id                 = var.vpc_id

  # Authentication: Mutual TLS or SAML 2.0
  authentication_options {
    type                       = var.authentication_type
    root_certificate_chain_arn = var.authentication_type == "certificate-authentication" ? var.client_certificate_arn : null
    saml_provider_arn          = var.authentication_type == "federated-authentication" ? var.saml_provider_arn : null
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client_vpn.name
  }

  tags = {
    Name        = "${var.environment}-client-vpn-endpoint"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AWS-Client-VPN-Architecture"
  }
}

# ------------------------------------------------------------------------------
# Multi-AZ Subnet Associations
# ------------------------------------------------------------------------------
resource "aws_ec2_client_vpn_network_association" "subnets" {
  count                  = length(var.associated_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  subnet_id              = var.associated_subnet_ids[count.index]
}

# ------------------------------------------------------------------------------
# Authorization Rules
# ------------------------------------------------------------------------------
resource "aws_ec2_client_vpn_authorization_rule" "ingress_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  target_network_cidr    = var.vpc_cidr
  authorize_all_groups   = true
  description            = "Grant all authenticated VPN users access to the local VPC CIDR"
}

# ------------------------------------------------------------------------------
# Client VPN Route Table Entries
# ------------------------------------------------------------------------------
resource "aws_ec2_client_vpn_route" "vpc_routes" {
  count                  = length(var.associated_subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.main.id
  destination_cidr_block = var.vpc_cidr
  target_vpc_subnet_id   = var.associated_subnet_ids[count.index]
  description            = "Route to internal VPC CIDR via association ${count.index}"
  depends_on             = [aws_ec2_client_vpn_network_association.subnets]
}
