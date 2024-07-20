/**
 * Copyright 2024 Google LLC
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

locals {
  subnet_region_name = { for subnet in var.exposure_subnets :
    subnet.region => "${subnet.region}/${subnet.name}"
  }
}

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = var.project_id
  name       = "apigee-network"
  subnets    = var.exposure_subnets
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
  }
}

module "nip-development-hostname" {
  source             = "../build/modules/nip-development-hostname"
  project_id         = var.project_id
  address_name       = "apigee-external"
  subdomain_prefixes = [for name, _ in var.apigee_envgroups : name]
}

module "apigee-x-core" {
  source              = "../build/modules/apigee-x-core"
  project_id          = var.project_id
  ax_region           = var.ax_region
  apigee_environments = var.apigee_environments
  apigee_envgroups    = var.apigee_envgroups
  apigee_instances    = var.apigee_instances
  network             = module.vpc.network.id
}

module "apigee-x-bridge-mig" {
  for_each    = var.apigee_instances
  source      = "../build/modules/apigee-x-bridge-mig"
  project_id  = var.project_id
  network     = module.vpc.network.id
  subnet      = module.vpc.subnet_self_links[local.subnet_region_name[each.value.region]]
  region      = each.value.region
  endpoint_ip = module.apigee-x-core.instance_endpoints[each.key]
}

module "mig-l7xlb" {
  source          = "../build/modules/mig-l7xlb"
  project_id      = var.project_id
  name            = "apigee-xlb"
  backend_migs    = [for _, mig in module.apigee-x-bridge-mig : mig.instance_group]
  ssl_certificate = [module.nip-development-hostname.ssl_certificate]
  external_ip     = module.nip-development-hostname.ip_address
}