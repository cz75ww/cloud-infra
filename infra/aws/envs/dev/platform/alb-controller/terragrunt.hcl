include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/alb-controller"
}

dependency "eks" {
  config_path = "../../eks"

  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "eks_addons" {
  config_path = "../eks-addons"  # PIA must be ready first!

  mock_outputs = {
    dummy = "dummy"
  }
  skip_outputs  = true
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  eks_name      = dependency.eks.outputs.cluster_name
  vpc_id        = dependency.vpc.outputs.vpc_id
  chart_version = "1.8.1"
}
