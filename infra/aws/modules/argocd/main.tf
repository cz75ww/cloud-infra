
resource "aws_eks_addon" "this" {
  for_each = var.addons

  cluster_name    = var.eks_name
  addon_name      = each.key
  addon_version   = try(each.value.addon_version, null)

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

}
