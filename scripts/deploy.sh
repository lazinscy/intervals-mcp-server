#!/usr/bin/env bash
# Deploy Intervals MCP Server via Terraform.
#
# Thin wrapper around terraform apply — builds Docker image, then applies
# the Terraform configuration with the given version.
#
# Secrets must be provided via TF_VAR_* env vars (use 1Password injection):
#   op run --env-file=.env -- scripts/deploy.sh 1.2.3
#
# Usage:
#   scripts/deploy.sh <version> [environment]
set -euo pipefail

VERSION="${1:?Usage: deploy.sh <version> [environment]}"
ENV="${2:-prod}"
WORKLOAD="intervals-mcp-server"

cd "$(dirname "$0")/../terraform"

# Derive ACR name from workload + env (must match Terraform naming).
ACR_NAME="${WORKLOAD//-/}${ENV}cr"
ACR_SERVER="${ACR_NAME}.azurecr.io"

echo "=== Deploying ${WORKLOAD} ${VERSION} (env: ${ENV}) ==="

# Phase 1: Ensure ACR exists (no-op on existing infra).
echo "[1/4] Ensuring ACR exists..."
terraform init -backend-config="key=${WORKLOAD}-${ENV}.tfstate"
terraform apply \
    -var-file="environments/${ENV}.tfvars" \
    -target=azurerm_resource_group.main \
    -target=azurerm_container_registry.acr

# Phase 2: Build and push Docker image.
echo "[2/4] Building and pushing image..."
az acr login --name "$ACR_NAME"
cd ..
docker buildx build --platform linux/amd64 \
    -t "${ACR_SERVER}/${WORKLOAD}:${VERSION}" \
    -t "${ACR_SERVER}/${WORKLOAD}:latest" \
    --push .
cd terraform

# Phase 3: Full Terraform apply.
echo "[3/4] Applying Terraform..."
terraform apply \
    -var-file="environments/${ENV}.tfvars" \
    -var="image_tag=${VERSION}"

# Verify.
echo "[4/4] Verifying deployment..."
sleep 15
FQDN=$(terraform output -raw app_fqdn)
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' "https://${FQDN}/mcp")
echo "MCP endpoint check: HTTP ${HTTP_CODE}"
echo "Deployed version: ${VERSION}"
if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "405" ]; then
    echo "Error: MCP endpoint check failed." >&2
    exit 1
fi

echo ""
echo "=== Deploy complete ==="
echo "MCP endpoint: https://${FQDN}/mcp"
