output "client_vpn_endpoint_id" {
  description = "The ID of the provisioned AWS Client VPN Endpoint"
  value       = aws_ec2_client_vpn_endpoint.main.id
}

output "client_vpn_endpoint_dns_name" {
  description = "The DNS name of the Client VPN endpoint (prefixed with *. for client profile)"
  value       = aws_ec2_client_vpn_endpoint.main.dns_name
}

output "client_vpn_security_group_id" {
  description = "The ID of the security group attached to the Client VPN subnet associations (use for SG chaining)"
  value       = aws_security_group.client_vpn.id
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group capturing connection telemetry"
  value       = aws_cloudwatch_log_group.client_vpn.name
}

output "quickstart_client_configuration_guide" {
  description = "Next steps to export and configure the OpenVPN client profile"
  value       = <<-EOT
    1. Export configuration profile:
       aws ec2 export-client-vpn-client-configuration --client-vpn-endpoint-id ${aws_ec2_client_vpn_endpoint.main.id} --output text > downloaded-client-config.ovpn
    
    2. Edit downloaded-client-config.ovpn and prepend a random string to the remote line:
       remote asdf123.${aws_ec2_client_vpn_endpoint.main.dns_name} ${var.vpn_port}
    
    3. Import downloaded-client-config.ovpn into the AWS Client VPN desktop app or standard OpenVPN client.
  EOT
}
