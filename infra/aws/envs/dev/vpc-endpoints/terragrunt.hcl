terraform {
  source = "../../../modules/vpc-endpoints/"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

include "region" {
  path   = find_in_parent_folders("region.hcl")
  expose = true
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id                  = "vpc-123456"
    vpc_cidr                = "10.0.0.0/16"
    private_subnet_ids      = ["subnet-123456", "subnet-789012"]
    private_route_table_ids = ["rtb-123456"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  env                     = include.env.locals.env
  region                  = include.region.locals.aws_region
  vpc_id                  = dependency.vpc.outputs.vpc_id
  vpc_cidr                = dependency.vpc.outputs.vpc_cidr
  private_subnet_ids      = dependency.vpc.outputs.private_subnet_ids
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids
}