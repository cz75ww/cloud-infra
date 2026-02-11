#!/usr/bin/env bash
set -euo pipefail

echo "Running kube setup ..."

mkdir -p /home/appuser/.kube
chown appuser:appuser /home/appuser/.kube 2>/dev/null || true

# Only try if kind is actually installed
if command -v kind >/dev/null 2>&1; then
    echo "kind detected → generating kubeconfig"
    kind get kubeconfig --name kind --internal > /home/appuser/.kube/config 2>/dev/null || {
        echo "Warning: kind kubeconfig generation failed (cluster may not exist yet)"
    }
    chmod 600 /home/appuser/.kube/config
    chown appuser:appuser /home/appuser/.kube/config
else
    echo "kind not found → skipping kubeconfig"
fi

# Bash enhancements — only if kubectl exists
if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl found → adding completions + alias"

    cat >> /home/appuser/.bashrc <<'INNER_EOF'
# Kubernetes helpers
if [[ -n "${BASH_VERSION:-}" ]]; then
    source <(kubectl completion bash 2>/dev/null || true)
    alias k='kubectl'
    complete -o default -F __start_kubectl k 2>/dev/null || true
fi
INNER_EOF

else
    echo "kubectl not found → no completions added"
fi

echo "Kube setup finished."