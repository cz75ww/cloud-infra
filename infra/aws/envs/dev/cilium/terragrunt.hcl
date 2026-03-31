include "root" {
  path   = "../root.hcl"
  expose = true 
}

include "kubernetes_addons" {
  path = "../_config/providers.hcl"
}

terraform {
  source = "${include.root.locals.base_module_url}//cilium"
}

dependency "eks" {
  config_path = "${include.root.locals.base_env_url}//eks"
  
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
  chart_version = "1.17.1"
  namespace     = "kube-system"
  
  wait          = false
  timeout       = 600 
  wait_for_jobs = false

  helm_values = {
    eni                        = { enabled = true }
    ipam                       = { mode = "eni" }
    egressMasqueradeInterfaces = "ens+"
    routingMode                = "native"
    kubeProxyReplacement       = "true"
    ipv4NativeRoutingCIDR      = "10.0.0.0/16"
    
    # Safe handling of the endpoint for initial validation
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

  # Adding these for consistency with your other modules
  aws_region = include.root.locals.aws_region
  env        = include.root.locals.env
}