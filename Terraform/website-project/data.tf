data "azurerm_dns_zone" "zone" {
  count               = var.existing_dns_zone_name == "" ? 0 : 1
  name                = var.existing_dns_zone_name
  resource_group_name = var.existing_dns_zone_resource_group
}