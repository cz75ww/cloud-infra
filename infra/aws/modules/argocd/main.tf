
resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name    = var.eks_name
  addon_name      = each.key
  addon_version   = try(each.value.addon_version, null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "kubectl_manifest" "argocd_app_of_apps" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: linkding
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: https://github.com/cz75ww/homelab-eks-apps-linkding.git
        targetRevision: HEAD
        path: .
        helm:
          valueFiles:
            - envs/dev/values.yaml
      destination:
        server: https://kubernetes.default.svc
        namespace: linkding-ns
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
        automated:
          selfHeal: true
          prune: true
  YAML
}

