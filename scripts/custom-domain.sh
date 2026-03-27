#!/usr/bin/env bash
# Configure custom domain with managed TLS certificate.
#
# Prerequisites:
#   1. Container App must be deployed (run deploy.sh first)
#   2. DNS CNAME record must exist:
#      intervals.lazinscy.pl CNAME <app-fqdn>
#      (get FQDN from: terraform -chdir=terraform output -raw app_fqdn)
#
# Usage:
#   scripts/custom-domain.sh
set -euo pipefail

HOSTNAME="intervals.lazinscy.pl"
APP_NAME="intervals-mcp-server-prod-app"
RG_NAME="intervals-mcp-server-prod-rg"
ENV_NAME="intervals-mcp-server-prod-env"

echo "=== Custom domain setup: ${HOSTNAME} ==="

# Verify the app exists.
FQDN=$(az containerapp show --name "$APP_NAME" --resource-group "$RG_NAME" \
    --query "properties.configuration.ingress.fqdn" -o tsv)
echo "App FQDN: ${FQDN}"
echo "Ensure DNS CNAME exists: ${HOSTNAME} -> ${FQDN}"
echo ""

# Step 1: Add custom hostname.
echo "[1/2] Adding hostname..."
az containerapp hostname add \
    --name "$APP_NAME" \
    --resource-group "$RG_NAME" \
    --hostname "$HOSTNAME"

# Step 2: Bind managed certificate (CNAME validation).
echo "[2/2] Binding managed certificate..."
az containerapp hostname bind \
    --name "$APP_NAME" \
    --resource-group "$RG_NAME" \
    --hostname "$HOSTNAME" \
    --environment "$ENV_NAME" \
    --validation-method CNAME

echo ""
echo "=== Done ==="
echo "MCP endpoint: https://${HOSTNAME}/mcp"
