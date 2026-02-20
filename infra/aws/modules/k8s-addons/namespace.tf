# Annotate ServiceAccount for IRSA (Secrets Store CSI needs this)
# Only for demonstration purposes - in production, you'd typically create a dedicated ServiceAccount for the addon and annotate that instead
resource "kubernetes_annotations" "default_sa_irsa" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "default"
    namespace = "default"
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.secrets_store_test.arn
  }
}