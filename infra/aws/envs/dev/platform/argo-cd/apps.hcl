locals {
    
  argocd_apps = [
    {
      name            = "linkding-app"
      repo_url        = "https://github.com/cz75ww/homelab-eks-argocd-apps.git"
      target_revision = "HEAD"
      path            = "linkding"
      values_file     = "envs/dev/values.yaml"
      namespace       = "linkding-ns"
    }
  ]
}