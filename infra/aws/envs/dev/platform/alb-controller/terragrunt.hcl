include "root" {
  # Nested 2 levels deep in platform/alb-controller
  path   = "../../root.hcl"
  expose = true
}

terraform {
  # Standardized source using base_module_url
  source = "${include.root.locals.base_module_url}//platform/alb-controller"
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}/eks"

  mock_outputs = {
    cluster_name = "eks-dev-demo"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "vpc" {
  config_path = "${include.root.locals.base_env_url}/vpc"

  mock_outputs = {
    vpc_id = "vpc-12345"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "eks_addons" {
  # Points to the platform/eks-addons neighbor
  config_path = "${include.root.locals.base_env_url}/platform/eks-addons"

  skip_outputs = true
  mock_outputs = {
    dummy = "dummy"
  }
}

inputs = {
  # Pulling from dependencies and root config
  env           = include.root.locals.env
  region        = include.root.locals.aws_region
  eks_name      = dependency.eks.outputs.cluster_name
  vpc_id        = dependency.vpc.outputs.vpc_id
  
  # Controller specific settings
  release_name  = "aws-load-balancer-controller"
  namespace     = "kube-system"
  chart_version = "1.8.1"

  tags = {
    Environment = include.root.locals.env
    Component   = "ingress-controller"
  }
}
