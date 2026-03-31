include "root" {
  # path   = "../_config/root.hcl"
  path   = find_in_parent_folders("root.hcl")
  expose = true
}


terraform {
  source = "${include.root.locals.base_module_url}//vpc"
}

inputs = {
  env          = include.root.locals.env
  cluster_name = "eks-${include.root.locals.env}-demo"
  region       = include.root.locals.aws_region

  azs             = ["${include.root.locals.aws_region}a", "${include.root.locals.aws_region}b"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/19", "10.0.96.0/19"]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Dynamic cluster name tag
    "kubernetes.io/cluster/eks-${include.root.locals.env}-demo" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-${include.root.locals.env}-demo" = "owned"
  }

  tags = {
    Environment = include.root.locals.env
    ManagedBy   = "Terragrunt"
    Project     = "EKS-Demo"
  }
}