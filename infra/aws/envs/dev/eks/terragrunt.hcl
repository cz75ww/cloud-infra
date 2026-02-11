terraform {
  source = "../../../modules/eks"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  eks_version = local.env_vars.locals.eks_version
  env         = include.env.locals.env
  eks_name    = "demo"
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  
  node_groups = {}
}

dependency "vpc" {
  config_path = "../vpc"
  
  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}