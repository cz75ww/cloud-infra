# resource "aws_subnet" "private" {
#   count = length(var.private_subnets)

#   vpc_id            = aws_vpc.this.id
#   cidr_block        = var.private_subnets[count.index]
#   availability_zone = var.azs[count.index]

#   tags = merge(
#     var.tags,
#     {
#       Name                         = "${var.env}-private-${var.azs[count.index]}"
#       "karpenter.sh/discovery"     = var.cluster_name
#       "kubernetes.io/role/internal-elb" = "1"
#     },
#     var.private_subnet_tags
#   )
# }

# resource "aws_subnet" "public" {
#   count = length(var.public_subnets)

#   vpc_id            = aws_vpc.this.id
#   cidr_block        = var.public_subnets[count.index]
#   availability_zone = var.azs[count.index]

#   tags = merge(
#     var.tags,
#     {
#       Name                              = "${var.env}-public-${var.azs[count.index]}"
#       "karpenter.sh/discovery"          = var.cluster_name
#       "kubernetes.io/role/elb"          = "1"
#     },
#     var.public_subnet_tags
#   )
# }
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name                         = "${var.env}-private-${var.azs[count.index]}"
      "karpenter.sh/discovery"     = var.cluster_name
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.private_subnet_tags
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.tags,
    {
      Name                              = "${var.env}-public-${var.azs[count.index]}"
      "kubernetes.io/role/elb"          = "1"
    },
    var.public_subnet_tags
  )
}