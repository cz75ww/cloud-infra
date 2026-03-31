include "root" {
  path   = "../../root.hcl"
  expose = true
}

# Keep providers/kubernetes config if you have a separate file for it
include "kubernetes_addons" {
  path   = "../../_config/providers.hcl"
}

locals {
  # Load your application-specific configurations
  apps        = read_terragrunt_config("${get_terragrunt_dir()}/apps.hcl")
  helm_values = read_terragrunt_config("${get_terragrunt_dir()}/helm_values.hcl")

  # Helper to inject common repo metadata into app lists
  argocd_apps = [for app in local.apps.locals.argocd_apps : merge(app, {
    repo_url        = local.apps.locals.repo_url
    target_revision = local.apps.locals.target_revision
    values_file     = local.apps.locals.values_file
  })]

  karpenter_nodes = [for app in local.apps.locals.karpenter_nodes : merge(app, {
    repo_url        = local.apps.locals.repo_url
    target_revision = local.apps.locals.target_revision
    values_file     = local.apps.locals.values_file
  })]

  grafana = [for app in local.apps.locals.grafana : merge(app, {
    repo_url        = local.apps.locals.repo_url
    target_revision = local.apps.locals.target_revision
    values_file     = local.apps.locals.values_file
  })]
}

terraform {
  source = "${include.root.locals.base_module_url}//platform/argocd"
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}/eks"
  
  mock_outputs = {
    cluster_name     = "eks-dev-demo"
    cluster_endpoint = "https://mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependencies {
  paths = ["${include.root.locals.base_env_url}/group-nodes"]
}

inputs = {
  eks_name        = dependency.eks.outputs.cluster_name
  
  release_name    = "argocd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  chart_version   = "7.7.11"
  namespace       = "argocd"
  
  argocd_apps     = local.argocd_apps
  karpenter_nodes = local.karpenter_nodes
  grafana         = local.grafana
  helm_values     = local.helm_values.locals.helm_values
  
  wait            = false
  timeout         = 600
}