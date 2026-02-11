resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name    = var.cluster_name 
  node_group_name = "${var.env}-${each.key}"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.subnet_ids

  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = each.key
  }

  tags = merge(
    lookup(each.value, "tags", {}),
    {
      "Name" = "${var.env}-${each.key}"
    }
  )

  depends_on = [aws_iam_role_policy_attachment.nodes]
}