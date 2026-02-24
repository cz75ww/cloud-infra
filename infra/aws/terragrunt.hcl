locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  account_id = local.account_vars.locals.account_id
  aws_region = local.region_vars.locals.aws_region
}

# Configure Terragrunt to use remote state
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "eks-terraform-state-${local.account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    #dynamodb_table = "terraform-locks"
    use_lockfile = true 

    s3_bucket_tags = {
      Owner = "terragrunt"
      Name  = "Terraform State Storage"
    }
    
    dynamodb_table_tags = {
      Owner = "terragrunt"
      Name  = "Terraform Lock Table"
    }
  }
  
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}