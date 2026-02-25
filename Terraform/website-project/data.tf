data "azurerm_dns_zone" "zone" {
  count               = var.existing_dns_zone_name == "" ? 0 : 1
  name                = var.existing_dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
}

data "azurerm_resource_group" "existing-rg" {
  count = var.existing_resource_group_name == "" ? 0 : 1
  name  = var.existing_resource_group_name
}