output "lbc_iam_policy_arn" {
  value = aws_iam_policy.lbc_iam_policy.arn 
}

output "lbc_iam_role_arn" {
  description = "AWS Load Balancer Controller IAM Role ARN"
  value = aws_iam_role.lbc_iam_role.arn
}

# Output: LBC Pod Identity Association ARN
output "lbc_pod_identity_association_arn" {
  description = "AWS Load Balancer Controller Pod Identity Association ARN"
  value       = aws_eks_pod_identity_association.lbc.association_arn
}