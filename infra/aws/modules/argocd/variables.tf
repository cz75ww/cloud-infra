variable "eks_name" {
  description = "Name of the EKS cluster (required for Kubernetes provider)"
  type        = string
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = ""
}

variable "repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = null
}

variable "chart" {
  description = "Helm chart name"
  type        = string
  default     = ""
}

variable "chart_version" {
  description = "Helm chart version"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace to install the release"
  type        = string
  default     = "default"
}

variable "create_namespace" {
  description = "Create the namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "wait" {
  description = "Wait for all resources to be ready before marking the release as successful"
  type        = bool
  default     = false
}

variable "wait_for_jobs" {
  description = "Wait for jobs to complete before marking the release as successful"
  type        = bool
  default     = false
}

variable "timeout" {
  description = "Time in seconds to wait for any individual Kubernetes operation"
  type        = number
  default     = 300
}

variable "helm_values" {
  description = "Helm values to pass to the chart (as a map/object, will be converted to YAML)"
  type        = any
  default     = {}
}

variable "set_values" {
  description = "Additional values to set using --set (list of {name, value, type})"
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  default = []
}

variable "set_sensitive_values" {
  description = "Additional sensitive values to set using --set-sensitive (list of {name, value, type})"
  type = list(object({
    name  = string
    value = string
    type  = optional(string)
  }))
  default     = []
  sensitive   = true
}

variable "addons" {
  description = "Map of EKS addons to enable"
  type = map(object({
    addon_version = optional(string)
  }))
  default = {}
}