variable "release_name" {
  description = "Helm release name"
  type        = string
}

variable "repository" {
  description = "Helm chart repository URL"
  type        = string
}

variable "chart" {
  description = "Helm chart name"
  type        = string
}

variable "chart_version" {
  description = "VHelm chart version"
  type        = string
}

variable "namespace" {
  description = "Namespace name to install the addon (default: kube-system)"
  type        = string
  default     = "kube-system"
}

variable "helm_values" {
  description = "Map of values to pass to the Helm chart (will be converted to YAML)"
  type        = any
  default     = {}
}