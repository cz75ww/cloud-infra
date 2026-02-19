include "root" {
  path = find_in_parent_folders()
}

include "kubernetes_addons" {
  path = "../../../../_common/k8s-addons.hcl"
}

terraform {
  source = "../../../../modules/k8s-addons"
}

dependency "eks" {
  config_path = "../../eks"
  
  mock_outputs = {
    cluster_name     = "mock-cluster"
    cluster_endpoint = "https://mock.example.com"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan", "destroy"]
}

dependencies {
  paths = ["../../group-nodes"]
}

inputs = {
  eks_name      = dependency.eks.outputs.cluster_name
  release_name  = "argocd"
  repository    = "https://argoproj.github.io/argo-helm"
  chart         = "argo-cd"
  chart_version = "7.7.11"
  namespace     = "argocd"
  
  wait    = false
  timeout = 600
  
  helm_values = {
    server = {
      service = {
        type = "NodePort"
      }
      ingress = {
        enabled = true
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"     = "ip"
          "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          "alb.ingress.kubernetes.io/conditions.argogrpc" = "[{\"field\":\"http-header\",\"httpHeaderConfig\":{\"httpHeaderName\":\"Content-Type\",\"values\":[\"application/grpc\"]}}]"
        }
      }
      extraArgs = ["--insecure"]
    }
  }
}

