locals {
  env = "dev"
  
  # Kubernetes version
  eks_version = "1.31"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terragrunt"
    Project     = "EKS-Demo"
  }
}