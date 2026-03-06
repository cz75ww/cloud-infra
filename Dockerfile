# Stage 1: Build Task using Go
FROM golang:1.24-bookworm AS builder

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install Task (official path)
RUN go install github.com/go-task/task/v3/cmd/task@latest

# Stage 2: Runtime image - Using Debian for better compatibility
FROM debian:bookworm-slim

# Metadata
LABEL maintainer="fabiano@example.com"
LABEL version="1.0"
LABEL description="DevOps toolbox with Terraform, Kubernetes, AWS tools, and Docker"

# Build arguments for version pinning
ARG KUSTOMIZE_VERSION=5.8.0
ARG ANSIBLE_VERSION=9.1.0

# Install runtime dependencies and Docker in a single layer
RUN apt-get update && apt-get install -y \
    ca-certificates \
    bash \
    curl \
    unzip \
    git \
    gnupg \
    python3 \
    python3-pip \
    vim \
    sudo \
    jq \
    bash-completion \
    apt-transport-https \
    lsb-release \
    iptables \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Task binary
COPY --from=builder /go/bin/task /usr/local/bin/task

# Install AWS CLI v2
RUN set -e; \
    curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    unzip -q awscliv2.zip; \
    ./aws/install; \
    rm -rf awscliv2.zip aws

# Install eksctl with dynamic version and checksum validation
RUN set -e; \
    ARCH=amd64; \
    PLATFORM="$(uname -s)_${ARCH}"; \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"; \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" \
    | grep "eksctl_${PLATFORM}.tar.gz" \
    | sha256sum -c -; \
    tar -xzf "eksctl_${PLATFORM}.tar.gz" -C /tmp; \
    install -m 0755 /tmp/eksctl /usr/local/bin/eksctl; \
    rm -f "eksctl_${PLATFORM}.tar.gz" /tmp/eksctl

# Install kubectl 
RUN set -e; \
    KUBECTL_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt); \
    curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
    curl -sLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"; \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c -; \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl; \
    rm kubectl kubectl.sha256

# Install Helm 
RUN set -e; \
    HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name'); \
    curl -sLO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"; \
    curl -sLO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum"; \
    sha256sum -c "helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum"; \
    tar -xzf "helm-${HELM_VERSION}-linux-amd64.tar.gz"; \
    install -m 0755 linux-amd64/helm /usr/local/bin/helm; \
    rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" "helm-${HELM_VERSION}-linux-amd64.tar.gz.sha256sum" linux-amd64

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash -s -- ${KUSTOMIZE_VERSION} /usr/local/bin

# Install Terraform 
RUN set -e; \
    TERRAFORM_VERSION=$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r '.current_version'); \
    curl -sLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"; \
    curl -sLO "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" "terraform_${TERRAFORM_VERSION}_SHA256SUMS" | sha256sum -c -; \
    unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin; \
    rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" "terraform_${TERRAFORM_VERSION}_SHA256SUMS"; \
    chmod +x /usr/local/bin/terraform

# Install Terragrunt 
RUN set -e; \
    TERRAGRUNT_VERSION=$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r '.tag_name' | sed 's/^v//'); \
    curl -sLO "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"; \
    curl -sLO "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS"; \
    grep "terragrunt_linux_amd64$" SHA256SUMS | sha256sum -c -; \
    install -m 0755 terragrunt_linux_amd64 /usr/local/bin/terragrunt; \
    rm terragrunt_linux_amd64 SHA256SUMS

# Install kind 
RUN set -e; \
    KIND_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/'); \
    curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64; \
    chmod +x /usr/local/bin/kind

# Install cilium-cli 
RUN set -e; \
    CILIUM_CLI_VERSION=$(curl -s https://api.github.com/repos/cilium/cilium-cli/releases/latest | jq -r '.tag_name'); \
    curl -sLO "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz"; \
    curl -sLO "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz.sha256sum"; \
    sha256sum -c "cilium-linux-amd64.tar.gz.sha256sum"; \
    tar -xzf "cilium-linux-amd64.tar.gz"; \
    install -m 0755 cilium /usr/local/bin/cilium; \
    rm -rf "cilium-linux-amd64.tar.gz" "cilium-linux-amd64.tar.gz.sha256sum" cilium

# Install k9s (latest stable)
RUN set -e; \
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name'); \
    curl -sL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" | tar -xz -C /tmp; \
    install -m 0755 /tmp/k9s /usr/local/bin/k9s; \
    rm -f /tmp/k9s

# Install ArgoCD CLI
RUN set -e; \
    ARGOCD_VERSION=$(curl -s https://api.github.com/repos/argoproj/argo-cd/releases/latest | jq -r '.tag_name'); \
    curl -sLO "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"; \
    curl -sLO "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/cli_checksums.txt"; \
    grep "argocd-linux-amd64$" cli_checksums.txt | sha256sum -c -; \
    install -m 0755 argocd-linux-amd64 /usr/local/bin/argocd; \
    rm -f argocd-linux-amd64 cli_checksums.txt

# Install Ansible with pinned version
RUN pip3 install --break-system-packages --no-cache-dir ansible==${ANSIBLE_VERSION}


# Create non-root user with sudo privileges
RUN useradd -m -u 1000 -s /bin/bash appuser && \
    echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    usermod -aG docker appuser

# Copy the setup script
COPY setup-kube.sh /home/appuser/setup-kube.sh

# Make executable + run it (single layer)
RUN chmod +x /home/appuser/setup-kube.sh && \
    /home/appuser/setup-kube.sh && \
    rm -f /home/appuser/setup-kube.sh

# Copy eks-platform folder to container
#COPY infra /app/infra

# Change ownership of /app to appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

CMD ["/bin/bash"]
