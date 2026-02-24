resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "azurerm_static_web_app" "swa" {
  name                = "swa-${var.project_name}-${var.environment}-${random_integer.suffix.result}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku_tier            = var.swa_sku
  sku_size            = var.swa_sku


  app_settings = var.ENV_Variables

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

resource "azurerm_dns_a_record" "custom_domain_apex" {
  count = local.is_apex_domain ? 1 : 0

  name                = "@"
  zone_name           = local.dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
  ttl                 = 3600
  target_resource_id  = azurerm_static_web_app.swa.id
}

resource "azurerm_dns_cname_record" "custom_domain_subdomain" {
  count = local.is_apex_domain ? 0 : 1

  name                = local.custom_domain_label
  zone_name           = local.dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
  ttl                 = 3600
  record              = azurerm_static_web_app.swa.default_host_name
}

resource "azurerm_static_web_app_custom_domain" "custom_domain" {
  static_web_app_id = azurerm_static_web_app.swa.id
  domain_name       = local.custom_domain_host
  validation_type   = "dns-txt-token"

  lifecycle {
    precondition {
      condition = local.is_apex_domain || endswith(local.custom_domain_lower, ".${local.dns_zone_name_lower}")
      error_message = "custom_domain must be the same as existing_dns_zone_name (apex) or a subdomain of it."
    }
  }

  depends_on = [
    azurerm_dns_a_record.custom_domain_apex,
    azurerm_dns_cname_record.custom_domain_subdomain
  ]
}

resource "azurerm_dns_txt_record" "custom_domain_validation" {
  name                = local.dns_txt_record_name
  zone_name           = local.dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
  ttl                 = 300

  record {
    value = azurerm_static_web_app_custom_domain.custom_domain.validation_token
  }

  lifecycle {
    ignore_changes = [record]
  }
}

resource "azurerm_storage_account" "backend" {
  name                     = "str${var.project_name}${var.environment}${random_integer.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}

resource "azurerm_storage_account_static_website" "backend_static" {
  storage_account_id = azurerm_storage_account.backend.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

resource "azurerm_storage_container" "content" {
  name                  = "content"
  storage_account_id    = azurerm_storage_account.backend.id
  container_access_type = "private"
}