resource "helm_release" "karpenter" {
  count            = var.install_helm_chart ? 1 : 0
  namespace        = var.karpenter_namespace
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.karpenter_version

  set {
    name  = "replicas"
    value = var.karpenter_replicas
  }

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = var.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "hostNetwork"
    value = "true"
  }

  set {
    name  = "dnsPolicy"
    value = "ClusterFirstWithHostNet"
  }

  timeout = var.helm_timeout

  depends_on = [
    aws_iam_role_policy_attachment.karpenter_controller_attach
  ]
}
