resource "aws_iam_role" "eks" {
  name = "${var.env}-${var.eks_name}-eks-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "this" {
  name     = var.eks_name
  version  = var.eks_version
  role_arn = aws_iam_role.eks.arn
  bootstrap_self_managed_addons = false

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = var.subnet_ids
  }
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_iam_role_policy_attachment.eks]
}

resource "aws_ec2_tag" "cluster_sg_node_discovery" {
  resource_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = "${var.env}-${var.eks_name}"
}