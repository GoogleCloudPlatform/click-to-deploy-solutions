/**
 * Copyright 2022 Google LLC
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

resource "random_password" "cloudsql_password" {
  length = 8
}

# create a VPC for CloudSQL
module "vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc?ref=v40.1.0"
  project_id = var.project_id
  name       = "sql-vpc"
  subnets = [
    {
      ip_cidr_range = var.ip_ranges.sql_vpc
      name          = "subnet"
      region        = var.region
    }
  ]
  psa_configs = [{
    ranges = {
      cloud-sql       = var.ip_ranges.psa
    }
    deletion_policy = "ABANDON"
  }]
}

# create a VPC connector for the ClouSQL VPC
#resource "google_vpc_access_connector" "connector" {
#  count         = var.create_connector ? 1 : 0
#  project       = var.project_id
#  name          = "wp-connector"
#  region        = var.region
#  ip_cidr_range = var.ip_ranges.connector
#  network       = module.vpc.self_link
#}

# Set up CloudSQL
module "cloudsql" {
  source           = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloudsql-instance?ref=v40.1.0"
  project_id       = var.project_id
  network_config = {
    connectivity = {
      psa_config = {
        private_network = module.vpc.self_link
      }
    }
  }
  name             = "mysql"
  region           = var.region
  database_version = local.cloudsql_conf.database_version
  tier             = local.cloudsql_conf.tier
  databases        = [local.cloudsql_conf.db]
  users = {
    admin = {
      "${local.cloudsql_conf.user}" = var.cloudsql_password
    }
  }
  gcp_deletion_protection       = false
  terraform_deletion_protection = false
}
