include "root" {
  # Standardized config path for nested modules
  path   = "../../root.hcl"
  expose = true
}

terraform {
  # Standardized source using our base_module_url
  source = "${include.root.locals.base_module_url}//platform/karpenter"
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}/eks"
  
  mock_outputs = {
    cluster_endpoint  = "https://mock-endpoint"
    cluster_name      = "eks-dev-demo"
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/mock"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "vpc" {
  config_path = "${include.root.locals.base_env_url}/vpc"
  
  mock_outputs = {
    vpc_id             = "vpc-mock"
    private_subnet_ids = ["subnet-mock1", "subnet-mock2"]
  }
}

# Ensure EKS is actually usable (Nodes + CNI) before installing the provisioner
dependencies {
  paths = [
    "${include.root.locals.base_env_url}/group-nodes", 
    "${include.root.locals.base_env_url}/cilium"
  ]
}

inputs = {
  # Using centralized variables
  env              = include.root.locals.env
  region           = include.root.locals.aws_region
  cluster_name     = dependency.eks.outputs.cluster_name
  cluster_endpoint = dependency.eks.outputs.cluster_endpoint
  
  # Karpenter specific settings
  karpenter_namespace = "karpenter"
  karpenter_version   = "1.8.6"
  karpenter_replicas  = 2
  install_helm_chart  = true
  helm_timeout        = 600
  
  tags = {
    Environment = include.root.locals.env
    ManagedBy   = "Terragrunt"
    Component   = "karpenter"
    Project     = "EKS-Demo"
  }
  
  helm_values = [{
    hostNetwork = true
    dnsPolicy   = "ClusterFirstWithHostNet"
  }]
}
