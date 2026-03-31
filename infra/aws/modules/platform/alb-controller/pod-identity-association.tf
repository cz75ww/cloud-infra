
resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = var.eks_name 
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc_iam_role.arn
}
