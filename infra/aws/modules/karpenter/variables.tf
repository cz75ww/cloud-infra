variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter"
  type        = string
  default     = "karpenter"
}

variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
  default     = "1.1.1"
}

variable "install_helm_chart" {
  description = "Whether to install Karpenter via Helm"
  type        = bool
  default     = true
}

variable "helm_timeout" {
  description = "Helm chart installation timeout in seconds"
  type        = number
  default     = 600
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "karpenter_replicas" {
  description = "Number of Karpenter replicas"
  type        = number
  default     = 1
}
