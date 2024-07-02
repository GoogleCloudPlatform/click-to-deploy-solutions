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

module "vpc" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/net-vpc?ref=v28.0.0"
  project_id = var.project_id
  name       = "apigee-network"
  subnets    = []
  psa_config = {
    ranges = {
      apigee-range         = var.peering_range
      apigee-support-range = var.support_range
    }
  }
}

module "apigee" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee?ref=v28.0.0"
  project_id          = var.project_id
  organization        = {
    authorized_network  = module.vpc.network.id
    analytics_region    = var.ax_region
  }
  environments        = var.apigee_environments
  envgroups           = var.apigee_envgroups
  instances           = var.apigee_instances
}