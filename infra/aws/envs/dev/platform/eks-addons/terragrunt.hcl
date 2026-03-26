include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/k8s-addons"
}

dependency "eks" {
  config_path = "../../eks"
  
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

locals {
  addons      = read_terragrunt_config("addons.hcl")
}

dependency "cilium" {
  config_path = "../../cilium"
  
  mock_outputs = {
    dummy = "dummy"
  }
  skip_outputs = true
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "nodes" {
  config_path = "../../group-nodes"
  
  mock_outputs = {
    dummy = "dummy"
  }
  skip_outputs = true
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  eks_name = dependency.eks.outputs.cluster_name
  release_name = "eks-addons-placeholder"
  addons = local.addons.locals.addons
  
}
