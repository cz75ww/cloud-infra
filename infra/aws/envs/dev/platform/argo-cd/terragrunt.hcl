include "root" {
  path = find_in_parent_folders()
}

include "kubernetes_addons" {
  path = "../../../../_common/k8s-addons.hcl"
}

terraform {
  source = "../../../../modules/argocd"
}

dependency "eks" {
  config_path = "../../eks"
  
  mock_outputs = {
    cluster_name     = "mock-cluster"
    cluster_endpoint = "https://mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependencies {
  paths = ["../../group-nodes"]
}

locals {
  apps          = read_terragrunt_config("apps.hcl")
 
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

  helm_values = read_terragrunt_config("helm_values.hcl")
}

inputs = {
  eks_name        = dependency.eks.outputs.cluster_name
  release_name    = "argocd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  chart_version   = "7.7.11"
  namespace       = "argocd"
  wait            = false
  timeout         = 600
  argocd_apps     = local.argocd_apps
  karpenter_nodes = local.karpenter_nodes
  grafana         = local.grafana
  helm_values     = local.helm_values.locals.helm_values
}