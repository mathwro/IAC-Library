Required RBAC Roles:

- `Static Web App Contributor` on the target resource group
- `DNS Zone Contributor` on the DNS zone resource group

## Custom domain support

This module supports both:

- Apex/primary domain (for example `website.com`)
- Subdomain (for example `projects.website.com`)

Set these variables:

- `custom_domain`: hostname or URL. The module extracts the hostname and uses it for DNS/custom-domain binding.
- `existing_dns_zone_name`: the DNS zone (for example `website.com`)
- `existing_dns_zone_resource_group`: resource group containing the DNS zone

Examples for `custom_domain`:

- `website.com`
- `projects.website.com`
- `https://website.com/projects/my-project` (hostname `website.com` is used)

### Apex domain example

```hcl
module "website" {
	source = "./Terraform/website-project"

	project_name                      = "myproject"
	subscription_id                   = var.subscription_id
	resource_group_name               = "rg-web"
	location                          = "West Europe"
	environment                       = "prod"
	custom_domain                     = "website.com"
	existing_dns_zone_name            = "website.com"
	existing_dns_zone_resource_group  = "rg-dns"
}
```

### Subdomain example

```hcl
module "website" {
	source = "./Terraform/website-project"

	project_name                      = "myproject"
	subscription_id                   = var.subscription_id
	resource_group_name               = "rg-web"
	location                          = "West Europe"
	environment                       = "prod"
	custom_domain                     = "projects.website.com"
	existing_dns_zone_name            = "website.com"
	existing_dns_zone_resource_group  = "rg-dns"
}
```