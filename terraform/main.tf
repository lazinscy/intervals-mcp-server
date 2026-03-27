# Intervals MCP Server — workload resources

locals {
  # Naming: <workload>-<env>-<suffix>
  rg_name  = "${var.workload}-${var.environment}-rg"
  acr_name = replace("${var.workload}${var.environment}cr", "-", "")
  env_name = "${var.workload}-${var.environment}-env"
  app_name = "${var.workload}-${var.environment}-app"
  log_name = "${var.workload}-${var.environment}-log"
  id_name  = "${var.workload}-${var.environment}-id"

  registry = "${local.acr_name}.azurecr.io"

  # Revision suffix: 1.2.3 -> v1-2-3, latest -> latest
  revision_suffix = (
    var.image_tag == "latest"
    ? "latest"
    : "v${replace(var.image_tag, ".", "-")}"
  )

  tags = {
    org         = "lazinscy"
    repo        = "intervals-mcp-server"
    managed-by  = "terraform"
    environment = var.environment
  }
}

# --- Resource Group ---

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# --- User-Assigned Managed Identity (created before app for ACR access) ---

resource "azurerm_user_assigned_identity" "app" {
  name                = local.id_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = local.tags
}

# --- Container Registry (admin disabled — use managed identity) ---

resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}

# --- ACR Pull role (granted before Container App creation) ---

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# --- Log Analytics Workspace ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# --- Container Apps Environment ---

resource "azurerm_container_app_environment" "main" {
  name                       = local.env_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.tags
}

# --- Container App ---

resource "azurerm_container_app" "app" {
  name                         = local.app_name
  resource_group_name          = azurerm_resource_group.main.name
  container_app_environment_id = azurerm_container_app_environment.main.id
  revision_mode                = "Single"
  tags                         = local.tags

  depends_on = [azurerm_role_assignment.acr_pull]

  lifecycle {
    ignore_changes = [
      template[0].revision_suffix,
      template[0].container[0].image,
    ]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  secret {
    name  = "intervals-api-key"
    value = var.intervals_api_key
  }

  secret {
    name  = "mcp-api-key"
    value = var.mcp_api_key
  }

  template {
    revision_suffix = local.revision_suffix

    min_replicas = 1
    max_replicas = 1

    container {
      name   = "intervals-mcp-server"
      image  = "${azurerm_container_registry.acr.login_server}/${var.workload}:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name  = "MCP_TRANSPORT"
        value = "streamable-http"
      }

      env {
        name        = "API_KEY"
        secret_name = "intervals-api-key"
      }

      env {
        name  = "ATHLETE_ID"
        value = var.intervals_athlete_id
      }

      env {
        name        = "MCP_API_KEY"
        secret_name = "mcp-api-key"
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}
