locals {
    
  karpenter_nodes = [
    {
      name            = "karpenter"
      repo_url        = "https://github.com/cz75ww/homelab-eks-argocd-apps.git"
      target_revision = "HEAD"
      path            = "karpenter"
      values_file     = "envs/dev/values.yaml"
      namespace       = "default"
    }
  ]
}