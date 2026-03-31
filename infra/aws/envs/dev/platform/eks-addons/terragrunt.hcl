include "root" {
  # We are deeper in the tree (platform/eks-addons), so we need ../../
  path   = "../../root.hcl"
  expose = true
}

terraform {
  # Standardized source path
  source = "${include.root.locals.base_module_url}//platform/eks-addons"
}

locals {
  # Load your specific addons list from the sibling file
  addons_vars = read_terragrunt_config("${get_terragrunt_dir()}/addons.hcl")
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}/eks"
  
  mock_outputs = {
    cluster_name = "eks-dev-demo"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

# We wait for Cilium and Nodes to ensure the cluster is ready for Addons (like CoreDNS)
dependency "cilium" {
  config_path  = "${include.root.locals.base_env_url}/cilium"
  skip_outputs = true
  mock_outputs = { dummy = "dummy" }
}

dependency "nodes" {
  config_path  = "${include.root.locals.base_env_url}/group-nodes"
  skip_outputs = true
  mock_outputs = { dummy = "dummy" }
}

inputs = {
  eks_name     = dependency.eks.outputs.cluster_name
  release_name = "eks-addons-${include.root.locals.env}"
  
  # Inject the addons list from your addons.hcl
  addons = local.addons_vars.locals.addons
  
  # Pass through common vars for tagging
  env    = include.root.locals.env
  region = include.root.locals.aws_region
}