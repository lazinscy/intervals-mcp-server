variable "environment" {
  type        = string
  description = "Environment name (prod, staging)"
  # No default — forces explicit selection.
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "westeurope"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "workload" {
  type        = string
  description = "Workload name used in resource naming"
  default     = "intervals-mcp-server"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy"
  default     = "latest"
}

variable "intervals_api_key" {
  type        = string
  description = "Intervals.icu API key for outbound API calls"
  sensitive   = true
}

variable "intervals_athlete_id" {
  type        = string
  description = "Intervals.icu athlete ID"
}

variable "mcp_api_key" {
  type        = string
  description = "Bearer token for incoming MCP client authentication"
  sensitive   = true
}

