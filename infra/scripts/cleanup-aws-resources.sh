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

# Get VPC ID for later SG/ENI cleanup
VPC_ID=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --query 'cluster.resourcesVpcConfig.vpcId' \
  --output text 2>/dev/null || echo "")
echo "==> VPC: $VPC_ID"

# Update kubeconfig to ensure kubectl works
aws eks update-kubeconfig --name "$CLUSTER_NAME" \
  --region "$(aws configure get region)" 2>/dev/null || true

# Delete ArgoCD applications to stop reconciliation
ARGOCD_APPS=$(kubectl get application -n argocd --no-headers 2>/dev/null | awk '{print $1}' || echo "")
if [ -n "$ARGOCD_APPS" ]; then
  echo "==> Deleting ArgoCD applications..."
  for APP in $ARGOCD_APPS; do
    echo "    Deleting app: $APP"
    kubectl delete application "$APP" -n argocd --ignore-not-found=true
  done
else
  echo "==> No ArgoCD applications found, skipping..."
fi

# Delete ingresses to trigger ALB controller cleanup
INGRESS_COUNT=$(kubectl get ingress --all-namespaces --no-headers 2>/dev/null | wc -l || echo "0")
if [ "$INGRESS_COUNT" -gt 0 ]; then
  echo "==> Found $INGRESS_COUNT ingress(es), deleting..."
  kubectl delete ingress --all --all-namespaces --ignore-not-found=true || true
  echo "==> Waiting for ALB controller to delete ALBs (60s)..."
  sleep 60
else
  echo "==> No ingresses found, skipping..."
fi

# Force delete any remaining ALBs tagged for this cluster
echo "==> Checking for orphaned ALBs..."
ARNS=$(aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].LoadBalancerArn' \
  --output text)

for ARN in $ARNS; do
  TAGS=$(aws elbv2 describe-tags \
    --resource-arns "$ARN" \
    --query "TagDescriptions[0].Tags[?Key=='elbv2.k8s.aws/cluster'].Value" \
    --output text)
  if [ "$TAGS" == "$CLUSTER_NAME" ]; then
    echo "==> Force deleting ALB: $ARN"
    aws elbv2 delete-load-balancer --load-balancer-arn "$ARN"
    sleep 10
  fi
done

# Delete orphaned target groups
echo "==> Checking for orphaned target groups..."
TG_ARNS=$(aws elbv2 describe-target-groups \
  --query 'TargetGroups[*].TargetGroupArn' \
  --output text)

for TG_ARN in $TG_ARNS; do
  TG_TAGS=$(aws elbv2 describe-tags \
    --resource-arns "$TG_ARN" \
    --query "TagDescriptions[0].Tags[?Key=='elbv2.k8s.aws/cluster'].Value" \
    --output text)
  if [ "$TG_TAGS" == "$CLUSTER_NAME" ]; then
    echo "==> Deleting target group: $TG_ARN"
    aws elbv2 delete-target-group --target-group-arn "$TG_ARN" || true
  fi
done

# Delete orphaned security groups created by AWS LB Controller
if [ -n "$VPC_ID" ]; then
  echo "==> Checking for orphaned security groups in VPC $VPC_ID..."
  SG_IDS=$(aws ec2 describe-security-groups \
    --filters "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
    --output text)

  for SG in $SG_IDS; do
    SG_NAME=$(aws ec2 describe-security-groups \
      --group-ids "$SG" \
      --query 'SecurityGroups[0].GroupName' \
      --output text)
    # Only delete SGs created by the LB controller (prefixed with k8s-elb or k8s-)
    if [[ "$SG_NAME" == k8s-* ]]; then
      echo "==> Deleting orphaned SG: $SG ($SG_NAME)"
      aws ec2 delete-security-group --group-id "$SG" || true
    fi
  done

  # Delete orphaned ENIs (status=available means nothing is using them)
  echo "==> Checking for orphaned ENIs in VPC $VPC_ID..."
  ENI_IDS=$(aws ec2 describe-network-interfaces \
    --filters \
      "Name=vpc-id,Values=$VPC_ID" \
      "Name=status,Values=available" \
    --query 'NetworkInterfaces[*].NetworkInterfaceId' \
    --output text)

  for ENI in $ENI_IDS; do
    echo "==> Deleting orphaned ENI: $ENI"
    aws ec2 delete-network-interface --network-interface-id "$ENI" || true
  done
fi

# Steps to avoid the Terraform destroy process getting stuck
# 1. Delete the stuck job/pod first to unblock
kubectl delete jobs --all -n kyverno --force --grace-period=0
kubectl delete pods --all -n kyverno --force --grace-period=0

# 2. Uninstall Helm release skipping hooks
helm uninstall kyverno -n kyverno --no-hooks

# 3. Clean up any remaining webhooks that could block future installs
kubectl delete validatingwebhookconfigurations -l app.kubernetes.io/instance=kyverno
kubectl delete mutatingwebhookconfigurations -l app.kubernetes.io/instance=kyverno

# 4. Delete the namespace if needed
kubectl delete namespace kyverno
echo ""
echo "==> Cleanup done!"