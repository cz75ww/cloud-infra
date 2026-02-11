terraform {
  source = "../../../modules/group-nodes/"
}

include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = find_in_parent_folders("env.hcl")
  expose = true
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs = {
    eks_version  = "1.31"
    subnet_ids   = ["subnet-123456"]
    cluster_name = "dev-demo"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

# Use dependencies block instead of dependency for Cilium
dependencies {
  paths = ["../cilium"]
}

inputs = {
  env          = include.env.locals.env
  eks_name     = "demo"
  cluster_name = dependency.eks.outputs.cluster_name
  eks_version  = dependency.eks.outputs.eks_version
  subnet_ids   = dependency.eks.outputs.subnet_ids
  
  node_groups = {
    general = {
      capacity_type  = "ON_DEMAND"
      instance_types = ["t3a.xlarge"]
      
      scaling_config = {
        desired_size = 1
        max_size     = 10
        min_size     = 1
      }
      
      taints = [
        {
          key    = "node.cilium.io/agent-not-ready"
          value  = "true"
          effect = "NO_EXECUTE" # Recommended for EKS 1.31+
        }
      ]
      
      labels = {
        role = "general"
      }
      
      tags = {
        "karpenter.sh/discovery" = dependency.eks.outputs.cluster_name
      }
    }
  }
}