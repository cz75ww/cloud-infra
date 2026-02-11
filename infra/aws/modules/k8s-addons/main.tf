resource "helm_release" "this" {
  count            = var.chart != "" ? 1 : 0
  name             = var.release_name
  repository       = var.repository
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace
  wait             = var.wait
  timeout          = var.timeout

  values = [yamlencode(var.helm_values)]
}

resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name    = var.eks_name
  addon_name      = each.key
  addon_version   = try(each.value.addon_version, null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}

