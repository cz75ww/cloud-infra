include "root" {
  path = find_in_parent_folders()
}

include "kubernetes_addons" {
  path = "../../../_common/k8s-addons.hcl"
}

terraform {
  source = "../../../modules/k8s-addons"
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs = {
    cluster_name     = "mock-cluster"
    cluster_endpoint = "https://mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

inputs = {
  eks_name      = dependency.eks.outputs.cluster_name
  release_name  = "cilium"
  repository    = "https://helm.cilium.io"
  chart         = "cilium"
  chart_version = "1.16.5"
  namespace     = "kube-system"
  
  wait          = false
  timeout       = 600 
  
  wait_for_jobs = false

  #  addons = {
  #   coredns = {
  #     addon_version = "v1.11.3-eksbuild.1" # Adjust version based on your EKS 1.31
  #   }
  # }
  
  helm_values = {
    eni = { enabled = true }
    ipam = { mode = "eni" }
    egressMasqueradeInterfaces = "eth0"
    routingMode                = "native"
    kubeProxyReplacement       = "true"
    
    #k8sServiceHost = trimprefix(dependency.eks.outputs.cluster_endpoint, "https://")
    k8sServiceHost = try(trimprefix(dependency.eks.outputs.cluster_endpoint, "https://"), "pending")
    
    k8sServicePort = 443
    
    hubble = {
      relay = { enabled = true }
      ui    = { enabled = true }
    }
    
    operator = {
      replicas = 1
    }
  }
}