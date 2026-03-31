include "root" {
  # Pointing up 2 levels to the _config folder
  path   = "../../root.hcl"
  expose = true
}

include "kubernetes_addons" {
  # Standardizing the provider config location
  path   = "../../_config/providers.hcl"
}

terraform {
  # Standardized source using base_module_url
  source = "${include.root.locals.base_module_url}//platform/kyverno"
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}/eks"
  
  mock_outputs = {
    cluster_name     = "eks-dev-demo"
    cluster_endpoint = "https://mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

# Soft dependencies for ordering
dependencies {
  paths = [
    "${include.root.locals.base_env_url}/group-nodes", 
    "${include.root.locals.base_env_url}/platform/argo-cd"
  ]
}

locals {
  # Load local helm values if they exist in this folder
  # If you don't have a helm_values.hcl here, you can define them directly in inputs
  helm_vars = read_terragrunt_config("${get_terragrunt_dir()}/helm_values.hcl", { locals = { helm_values = {} } })
}

inputs = {
  eks_name      = dependency.eks.outputs.cluster_name
  release_name  = "kyverno"
  repository    = "https://kyverno.github.io/kyverno/"
  chart         = "kyverno"
  chart_version = "3.4.4"
  namespace     = "kyverno"
  
  wait          = false
  timeout       = 600
  
  # Merging common env tags with Kyverno specific inputs
  env         = include.root.locals.env
  helm_values = local.helm_vars.locals.helm_values
}