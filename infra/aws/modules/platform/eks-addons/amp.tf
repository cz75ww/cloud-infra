resource "aws_prometheus_workspace" "amp" {
  alias = "${var.eks_name}-amp"
  tags  = var.tags
}
