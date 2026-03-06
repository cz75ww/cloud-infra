variable "vpc_id" {
  description = "VPC ID where endpoints will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block, used for security group ingress rule"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, used for tagging"
  type        = string
  default     = "unknown"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for Interface endpoints"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "List of private route table IDs for Gateway endpoints (S3)"
  type        = list(string)
}

variable "vpc_endpoints" {
  description = "Map of VPC endpoints to create. Key is service name, value is endpoint type."
  type        = map(string)
  default = {
    elasticloadbalancing = "Interface"
    ec2                  = "Interface"
    acm                  = "Interface"
    sts                  = "Interface"
    "ecr.api"            = "Interface"
    "ecr.dkr"            = "Interface"
    s3                   = "Gateway"
  }
}