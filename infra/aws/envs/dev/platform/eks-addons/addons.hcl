locals {
    
  addons = {
    coredns = {
      addon_version = "v1.11.4-eksbuild.28"
    }
    eks-pod-identity-agent = {
      addon_version = "v1.3.10-eksbuild.2"
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.56.0-eksbuild.1"
    }
    aws-secrets-store-csi-driver-provider = {
      addon_version = "v2.1.1-eksbuild.1"
    }
    external-dns = {
      addon_version = "v0.20.0-eksbuild.3"
    }
    prometheus-node-exporter = {
      addon_version = "v1.10.2-eksbuild.8"
    }
    kube-state-metrics = {
      addon_version = "v2.18.0-eksbuild.1"
    }
    # Cert-manager is required for opentelemetry-operator, which is a dependency for ADOT. We need to install it first before ADOT.
    cert-manager = {
    addon_version = "v1.19.2-eksbuild.1"
    }
    adot = {
      addon_version = "v0.131.0-eksbuild.1"
      configuration_values = jsonencode({
        manager = {
          resources = {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
        replicaCount = 1
      })
    }
  }
}