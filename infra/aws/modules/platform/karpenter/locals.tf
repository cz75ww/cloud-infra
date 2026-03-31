# Get the cluster security group ID (Updated reference to .this)
locals {
  cluster_security_group_id = data.aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}