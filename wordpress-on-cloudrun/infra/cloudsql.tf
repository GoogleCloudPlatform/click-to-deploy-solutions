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

# create a VPC connector for the ClouSQL VPC
#resource "google_vpc_access_connector" "connector" {
#  count         = var.create_connector ? 1 : 0
#  project       = var.project_id
#  name          = "wp-connector"
#  region        = var.region
#  ip_cidr_range = var.ip_ranges.connector
#  network       = module.vpc.network_self_link
#}

resource "google_sql_database_instance" "cloud_sql" {
  name             = "mysql-db"
  database_version = "MYSQL_5_7"
  region           = var.region
  project          = var.project_id
  settings {
    tier                  = "db-g1-small"
    user_labels           = local.resource_labels
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"

    ip_configuration {
      authorized_networks {
        name  = "default_network"
        value = "0.0.0.0/0"
      }
    }

#    ip_configuration {
#      ipv4_enabled    = false
#      private_network = module.vpc.network_self_link
#    }
  }
  deletion_protection = false
}

resource "google_sql_user" "users" {
  name     = "wp-user"
  instance = google_sql_database_instance.cloud_sql.name
  password = random_password.cloudsql_password.result
}