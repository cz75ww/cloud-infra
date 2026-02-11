output "eks_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = aws_eks_cluster.this.version
}

output "openid_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.this[0].arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider (alias)"
  value       = aws_iam_openid_connect_provider.this[0].arn
}

output "oidc_provider" {
  description = "OIDC provider URL without https://"
  value       = replace(aws_iam_openid_connect_provider.this[0].url, "https://", "")
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = aws_eks_cluster.this.role_arn
}

output "eks_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.this.version
}

output "subnet_ids" {
  description = "The subnet IDs associated with the EKS cluster"
  value       = aws_eks_cluster.this.vpc_config[0].subnet_ids
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}