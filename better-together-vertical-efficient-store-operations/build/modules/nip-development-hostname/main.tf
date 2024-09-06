/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_global_address" "external_address" {
  name         = var.address_name
  project      = var.project_id
  address_type = "EXTERNAL"
}

locals {
  hostname   = "${replace(google_compute_global_address.external_address.address, ".", "-")}.nip.io"
  subdomains = [for subdomain in var.subdomain_prefixes : "${subdomain}.${local.hostname}"]
  certname   = "cert-${replace(google_compute_global_address.external_address.address, ".", "")}"
  domains    = concat([local.hostname], local.subdomains)
}

resource "google_compute_managed_ssl_certificate" "google_cert" {
  project = var.project_id
  name    = local.certname
  managed {
    domains = local.domains
  }
}