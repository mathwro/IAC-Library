output "static_web_app_name" {
  description = "The name of the Static Web App"
  value       = azurerm_static_web_app.swa.name
}

output "static_web_app_url" {
  description = "The default URL of the Static Web App"
  value       = azurerm_static_web_app.swa.default_host_name
}

output "static_web_app_id" {
  description = "The ID of the Static Web App"
  value       = azurerm_static_web_app.swa.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.backend.name
}

output "storage_account_primary_web_endpoint" {
  description = "The primary web endpoint of the storage account"
  value       = azurerm_storage_account.backend.primary_web_endpoint
}

output "environment" {
  description = "The deployment environment"
  value       = var.environment
}

output "resolved_custom_domain_host" {
  description = "The hostname extracted from custom_domain and used for DNS and Static Web App custom-domain binding"
  value       = local.custom_domain_host
}
