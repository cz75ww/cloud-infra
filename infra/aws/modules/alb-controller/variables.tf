variable "eks_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "chart_version" {
  description = "ALB Controller Helm chart version"
  type        = string
  default     = "1.8.1"
}