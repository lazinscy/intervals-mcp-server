output "app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "app_url" {
  description = "Container App URL"
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}"
}

output "mcp_endpoint" {
  description = "MCP server endpoint"
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}/mcp"
}

output "acr_login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.acr.login_server
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}
