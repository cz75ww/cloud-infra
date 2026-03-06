resource "aws_vpc_endpoint" "this" {
  for_each = var.vpc_endpoints

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = each.value
  subnet_ids          = each.value == "Gateway" ? null : var.private_subnet_ids
  security_group_ids  = each.value == "Gateway" ? null : [aws_security_group.vpc_endpoints.id]
  route_table_ids     = each.value == "Gateway" ? var.private_route_table_ids : null
  private_dns_enabled = each.value == "Gateway" ? false : true

  tags = {
    Name        = "${var.cluster_name}-${each.key}"
    Environment = var.env
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.cluster_name}-vpc-endpoints"
  description = "Allow HTTPS from within VPC for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-vpc-endpoints"
    Environment = var.env
  }
}