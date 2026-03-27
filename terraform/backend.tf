terraform {
  backend "azurerm" {
    resource_group_name  = "infra-rg"
    storage_account_name = "lazinscytfstate"
    container_name       = "tfstate"
    key                  = "intervals-mcp-server-prod.tfstate"
  }
}
