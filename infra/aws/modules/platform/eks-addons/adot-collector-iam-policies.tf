resource "aws_iam_policy" "adot_collector" {
  name        = "${var.eks_name}-adot-collector-policy"
  description = "IAM policy for ADOT collector to write to AMP"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.amp.arn
      }
    ]
  })
  tags = var.tags
}