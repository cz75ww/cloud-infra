dependency "eks" {
  config_path = "../../eks"
}

dependency "cilium" {
  config_path = "../../cilium"
}

dependency "nodes" {
  config_path = "../../group-nodes"
}

# This forces Terragrunt to ensure the Cluster, the Network and the EC2s exist before trying to put CoreDNS on them.
inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
  
  # We leave helm_release empty here because Cilium is handled by the 'cilium' dependency folder.
  release_name = "eks-addons-placeholder" 

  addons = {
    coredns = {
      # Tip: Run 'aws eks describe-addon-versions' to get the right string
      addon_version = "v1.11.3-eksbuild.1" 
    }
  }
}