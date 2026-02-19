include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../modules/karpenter"
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    eks_name              = "mock-cluster"
    cluster_endpoint      = "https://mock-endpoint"
    oidc_provider_arn     = "arn:aws:iam::123456789012:oidc-provider/mock"
    oidc_provider         = "oidc.eks.us-east-1.amazonaws.com/id/MOCK"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id             = "vpc-mock"
    private_subnet_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

dependencies {
  paths = ["../group-nodes", "../cilium"]
}

locals {
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
}

inputs = {
  cluster_name        = "dev-demo"
  cluster_endpoint    = dependency.eks.outputs.cluster_endpoint
  region              = local.region_vars.locals.aws_region
  karpenter_namespace = "karpenter"
  karpenter_version   = "1.8.6"
  karpenter_replicas  = 1
  install_helm_chart  = true
  helm_timeout        = 600
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terragrunt"
    Component   = "karpenter"
    Project     = "EKS-Demo"
  }
  
  helm_values = [{
    hostNetwork = true
    dnsPolicy   = "ClusterFirstWithHostNet"
  }]
}
