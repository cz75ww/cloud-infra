resource "helm_release" "this" {
  name       = var.release_name
  repository = var.repository
  chart      = var.chart
  version    = var.chart_version
  namespace  = var.namespace
  wait       = false
  
  # Import values from the input variable and convert to YAML
  create_namespace = true

  values = [
    yamlencode(var.helm_values)
  ]
}

