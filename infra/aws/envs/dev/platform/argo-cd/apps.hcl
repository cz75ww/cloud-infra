locals {
  repo_url        = "https://github.com/cz75ww/homelab-eks-argocd-apps.git"
  target_revision = "HEAD"
  values_file     = "envs/dev/values.yaml"

  argocd_apps = [
    {
      name      = "linkding-app"
      path      = "linkding"
      namespace = "linkding-ns"
    }
  ]

  karpenter_nodes = [
    {
      name      = "karpenter"
      path      = "karpenter"
      namespace = "karpenter"
    }
  ]

  grafana = [
    {
      name      = "grafana"
      path      = "grafana"
      namespace = "grafana-ns"
    }
  ]
  
}