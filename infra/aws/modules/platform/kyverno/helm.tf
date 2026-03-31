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
