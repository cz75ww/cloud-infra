include "root" {
  # Explicit path to our standardized config
  path   = "../root.hcl"
  expose = true
}

terraform {
  # Scenario A: assuming your module is at /app/infra/aws/modules/group-nodes
  source = "${include.root.locals.base_module_url}//group-nodes"
}

dependency "eks" {
  # Using the base_env_url for stable pathing
  config_path = "${include.root.locals.base_env_url}/eks"
  
  mock_outputs = {
    eks_version  = "1.33"
    subnet_ids   = ["subnet-123456"]
    cluster_name = "eks-dev-demo"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

# Ensures Cilium is installed before nodes attempt to join/schedule
dependencies {
  paths = ["${include.root.locals.base_env_url}/cilium"]
}

inputs = {
  # Dynamic values from root/env.hcl
  env          = include.root.locals.env
  eks_name     = "eks-${include.root.locals.env}-demo"
  cluster_name = dependency.eks.outputs.cluster_name
  eks_version  = dependency.eks.outputs.eks_version
  subnet_ids   = dependency.eks.outputs.subnet_ids
  
  node_groups = {
    general = {
      # Pulling the version dynamically from your env.hcl
      eks_version    = include.root.locals.env_vars.locals.eks_version
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
          effect = "NO_EXECUTE"
        }
      ]
      
      labels = {
        role = "general"
        env  = include.root.locals.env
      }
      
      tags = {
        "karpenter.sh/discovery" = dependency.eks.outputs.cluster_name
        Environment              = include.root.locals.env
      }
    }
  }
}