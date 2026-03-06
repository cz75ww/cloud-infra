output "vpc_endpoint_ids" {
  description = "Map of VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.this : k => v.id }
}

output "security_group_id" {
  description = "Security group ID attached to Interface endpoints"
  value       = aws_security_group.vpc_endpoints.id
}