include "root" {
  path   = "../root.hcl"
  expose = true
}

terraform {
  source = "${include.root.locals.base_module_url}//vpc-endpoints"
}

dependency "vpc" {
  config_path = "${include.root.locals.base_env_url}/vpc"
  
  mock_outputs = {
    vpc_id                  = "vpc-123456"
    vpc_cidr                = "10.0.0.0/16"
    private_subnet_ids      = ["subnet-123456", "subnet-789012"]
    private_route_table_ids = ["rtb-123456"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  env    = include.root.locals.env
  region = include.root.locals.aws_region
  
  vpc_id                  = dependency.vpc.outputs.vpc_id
  vpc_cidr                = dependency.vpc.outputs.vpc_cidr
  private_subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
}