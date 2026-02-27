locals {
  env = "dev"
  
  # Kubernetes version
  eks_version = "1.33"
  
  tags = {
    Environment = "dev"
    ManagedBy   = "Terragrunt"
    Project     = "EKS-Demo"
  }
}