resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn
}

resource "aws_eks_pod_identity_association" "secrets_store_test" {
  cluster_name    = var.eks_name
  namespace       = "default"
  service_account = "default"
  role_arn        = aws_iam_role.secrets_store_test.arn
}