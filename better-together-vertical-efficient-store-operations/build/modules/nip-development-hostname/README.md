# NIP.io Hostname for Development

Creates an external IP address and a Google-managed certificate (for the hostname encoded IP) to be used with an external load balancer during development.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.external_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_managed_ssl_certificate.google_cert](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_name"></a> [address\_name](#input\_address\_name) | Name for the external IP address | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID. | `string` | n/a | yes |
| <a name="input_subdomain_prefixes"></a> [subdomain\_prefixes](#input\_subdomain\_prefixes) | Subdomain prefixes for the nip hostname (Optional). | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hostname"></a> [hostname](#output\_hostname) | Generated hostname (nip.io encoded IP address). |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | Reserved external IP address. |
| <a name="output_ssl_certificate"></a> [ssl\_certificate](#output\_ssl\_certificate) | Google-managed SSL certificate |
| <a name="output_subdomains"></a> [subdomains](#output\_subdomains) | List of generated subdomains (subdomain prefixes plus nip.io encoded IP address) |
<!-- END_TF_DOCS -->