##############################################
# ebs_csi Pod Identity Association
##############################################
resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = var.eks_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi.arn
}

##############################################
# SecretStore Pod Identity Association
##############################################
resource "aws_eks_pod_identity_association" "secrets_store" {
  cluster_name    = var.eks_name
  namespace       = "default"
  service_account = "default"
  role_arn        = aws_iam_role.secrets_store.arn
}

##############################################
# ExternalDNS Pod Identity Association
##############################################
resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = var.eks_name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.externaldns_role.arn
}