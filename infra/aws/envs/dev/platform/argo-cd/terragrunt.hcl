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
  karpenter   = read_terragrunt_config("karpenter.hcl")
  apps        = read_terragrunt_config("apps.hcl")
  helm_values = read_terragrunt_config("helm_values.hcl")
}

inputs = {
  eks_name      = dependency.eks.outputs.cluster_name
  release_name  = "argocd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "7.7.11"
  namespace     = "argocd"
  
  wait    = false
  timeout = 600

  karpenter_nodes = local.karpenter.locals.karpenter_nodes
  argocd_apps     = local.apps.locals.argocd_apps
  helm_values     = local.helm_values.locals.helm_values

}