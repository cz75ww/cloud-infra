include "root" {
  # Explicit path to our sibling config folder
  path   = "../root.hcl"
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}//eks"
}

dependency "vpc" {
  config_path = "${include.root.locals.base_env_url}/vpc"
  
  mock_outputs = {
    private_subnet_ids = ["subnet-1234", "subnet-5678"]
  }
}

dependencies {
  paths = ["${include.root.locals.base_env_url}/vpc-endpoints"]
}

inputs = {
  # Pull these from your env.hcl and root.hcl
  eks_version = include.root.locals.env_vars.locals.eks_version
  env         = include.root.locals.env
  
  # Dynamic naming based on environment
  eks_name    = "eks-${include.root.locals.env}-demo"
  subnet_ids  = dependency.vpc.outputs.private_subnet_ids
  
  node_groups = {}
}