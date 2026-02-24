include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../modules/k8s-addons"
}

dependency "eks" {
  config_path = "../../eks"
  
  mock_outputs = {
    cluster_name = "mock-cluster"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "cilium" {
  config_path = "../../cilium"
  
  mock_outputs = {
    dummy = "dummy"
  }
  skip_outputs = true
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependency "nodes" {
  config_path = "../../group-nodes"
  
  mock_outputs = {
    dummy = "dummy"
  }
  skip_outputs = true
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  eks_name = dependency.eks.outputs.cluster_name
  release_name = "eks-addons-placeholder"
  
  addons = {
    coredns = {
      addon_version = "v1.11.3-eksbuild.2"
    }
    eks-pod-identity-agent = {
      addon_version = "v1.3.4-eksbuild.1"
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.37.0-eksbuild.1"
    }
    aws-secrets-store-csi-driver-provider = {
      addon_version = "v2.1.1-eksbuild.1"
    }
    external-dns = {
      addon_version = "v0.20.0-eksbuild.3"
    }
  }
}
