
resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name    = var.eks_name
  addon_name      = each.key
  addon_version   = try(each.value.addon_version, null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

resource "kubectl_manifest" "argocd_apps" {
  for_each = { for app in var.argocd_apps : app.name => app }

  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${each.value.name}
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: ${each.value.repo_url}
        targetRevision: ${each.value.target_revision}
        path: ${each.value.path}
        helm:
          valueFiles:
            - ${each.value.values_file}
      destination:
        server: https://kubernetes.default.svc
        namespace: ${each.value.namespace}
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
        automated:
          selfHeal: true
          prune: true
  YAML
}

