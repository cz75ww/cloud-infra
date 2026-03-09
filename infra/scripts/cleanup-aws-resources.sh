#!/bin/bash
set -euo pipefail

CLUSTER_NAME=${1:-$(aws eks list-clusters --query 'clusters[0]' --output text)}

echo "==> Cluster: $CLUSTER_NAME"

# Check if EKS cluster exists and is reachable
if [ -z "$CLUSTER_NAME" ] || [ "$CLUSTER_NAME" == "None" ]; then
  echo "==> No EKS cluster found, skipping cleanup..."
  exit 0
fi

CLUSTER_STATUS=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --query 'cluster.status' \
  --output text 2>/dev/null || echo "NOT_FOUND")

if [ "$CLUSTER_STATUS" != "ACTIVE" ]; then
  echo "==> Cluster status is $CLUSTER_STATUS, skipping cleanup..."
  exit 0
fi

# Delete ingresses to trigger ALB controller cleanup
INGRESS_COUNT=$(kubectl get ingress --all-namespaces --no-headers 2>/dev/null | wc -l || echo "0")

if [ "$INGRESS_COUNT" -gt 0 ]; then
  echo "==> Found $INGRESS_COUNT ingress(es), deleting..."
  kubectl delete ingress --all --all-namespaces || true

  echo "==> Waiting for ALB controller to delete ALBs..."
  sleep 60

  # Check if any ALBs are still around and force delete them
  ARNS=$(aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[*].LoadBalancerArn' \
    --output text)

  for ARN in $ARNS; do
    TAGS=$(aws elbv2 describe-tags \
      --resource-arns "$ARN" \
      --query "TagDescriptions[0].Tags[?Key=='cluster'].Value" \
      --output text)
    if [ "$TAGS" == "$CLUSTER_NAME" ]; then
      echo "==> Force deleting ALB: $ARN"
      aws elbv2 delete-load-balancer --load-balancer-arn "$ARN"
      sleep 30
    fi
  done
else
  echo "==> No ingresses found, skipping..."
fi

echo "==> Cleanup done!"