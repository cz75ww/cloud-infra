locals {
  
  helm_values = {
    # Input values for ingress configuration
    server = {
      service = {
        type = "NodePort"
      }
      ingress = {
        enabled          = true
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"      = "ip"
          "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          "alb.ingress.kubernetes.io/conditions.argogrpc" = "[{\"field\":\"http-header\",\"httpHeaderConfig\":{\"httpHeaderName\":\"Content-Type\",\"values\":[\"application/grpc\"]}}]"
        }
      }
      extraArgs = ["--insecure"]
    }
  }
}