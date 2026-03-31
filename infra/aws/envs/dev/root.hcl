locals {
  config_dir = get_parent_terragrunt_dir()

  account_vars = read_terragrunt_config("${local.config_dir}/_config/account.hcl")
  region_vars  = read_terragrunt_config("${local.config_dir}/_config/region.hcl")
  env_vars     = read_terragrunt_config("${local.config_dir}/_config/env.hcl")

  # Extract values
  account_id  = local.account_vars.locals.account_id
  aws_region  = local.region_vars.locals.aws_region
  env         = local.env_vars.locals.env

  # Build paths
  base_module_url = "/app/infra/aws/modules"
  base_env_url    = "/app/infra/aws/envs/${local.env}"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "eks-terraform-state-${local.account_id}"
    region         = local.aws_region
    key            = "${local.env}/${path_relative_to_include()}/terraform.tfstate"
    encrypt        = true
    use_lockfile   = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}