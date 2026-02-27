variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "eks_name" {
  description = "Name prefix for the resources"
  type        = string
}

variable "cluster_name" {
  description = "The actual name of the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where nodes will be launched"
  type        = list(string)
}

variable "node_groups" {
  description = "Map of managed node group configurations"
  type        = any
}

variable "node_iam_policies" {
  description = "List of IAM Policies to attach to EKS-managed nodes."
  type        = map(any)
  default = {
    1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    2 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    3 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    4 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
