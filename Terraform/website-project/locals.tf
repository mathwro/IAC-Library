locals {
  dns_zone_name              = data.azurerm_dns_zone.zone[0].name
  custom_domain_input        = trimspace(var.custom_domain)
  custom_domain_no_scheme    = replace(replace(local.custom_domain_input, "https://", ""), "http://", "")
  custom_domain_host_raw     = split("/", local.custom_domain_no_scheme)[0]
  custom_domain_host_no_port = split(":", local.custom_domain_host_raw)[0]
  custom_domain_host         = trim(local.custom_domain_host_no_port, ".")
  custom_domain_lower        = lower(local.custom_domain_host)
  dns_zone_name_lower        = lower(trim(local.dns_zone_name, " "))
  is_apex_domain             = local.custom_domain_lower == local.dns_zone_name_lower
  custom_domain_without_zone = trimsuffix(local.custom_domain_lower, ".${local.dns_zone_name_lower}")
  custom_domain_label        = trim(local.custom_domain_without_zone, ".")
  dns_txt_record_name        = local.is_apex_domain ? "_dnsauth" : "_dnsauth.${local.custom_domain_label}"
}