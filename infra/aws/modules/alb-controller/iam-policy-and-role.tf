resource "aws_iam_policy" "lbc_iam_policy" {
  name        = "${var.eks_name}-AWSLoadBalancerControllerIAMPolicy"  
  path        = "/"
  description = "AWS Load Balancer Controller IAM Policy"
  policy      = data.http.lbc_iam_policy.response_body
}

resource "aws_iam_role" "lbc_iam_role" {
  name = "${var.eks_name}-lbc-iam-role"  

 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = {
    Name      = "${var.eks_name}-lbc-iam-role"
    Component = "AWS Load Balancer Controller"
  }
}

resource "aws_iam_role_policy_attachment" "lbc_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.lbc_iam_policy.arn
  role       = aws_iam_role.lbc_iam_role.name
}

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}

resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = var.eks_name 
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc_iam_role.arn
}
