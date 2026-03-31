
# resource "aws_eks_addon" "this" {
#   for_each = var.addons

#   cluster_name    = var.eks_name
#   addon_name      = each.key
#   addon_version   = try(each.value.addon_version, null)
#   configuration_values        = try(each.value.configuration_values, null)

#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"

# }

# 1. Install standard addons first
resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.addons : k => v if k != "adot" }

  cluster_name                = var.eks_name
  addon_name                  = each.key
  addon_version               = try(each.value.addon_version, null)
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# 2. Install adot only after standard addons created
resource "aws_eks_addon" "dependent" {
  for_each = { for k, v in var.addons : k => v if k == "adot" }

  cluster_name                = var.eks_name
  addon_name                  = each.key
  addon_version               = try(each.value.addon_version, null)
  configuration_values        = try(each.value.configuration_values, null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # The Magic Line: ADOT waits for EVERYTHING in the first loop
  depends_on = [aws_eks_addon.this]
}
