# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  db_instance_name = "mysql-${random_id.db_name_suffix.hex}"
  datastream_ips = ["35.199.77.203", "35.198.52.22", "35.198.0.15", "35.247.212.140", "34.95.239.160"]
}

resource "random_id" "db_name_suffix" {
  byte_length = 2
}

resource "google_sql_database_instance" "cloud_sql" {
  name                = local.db_instance_name
  region              = var.region
  database_version    = "MYSQL_8_0"
  deletion_protection = false # not recommended for PROD

  settings {
    tier        = "db-custom-1-3840"
    user_labels = local.resource_labels

    backup_configuration {
      enabled            = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = true
      private_network = module.vpc.network_self_link

      dynamic "authorized_networks" {
        for_each = local.datastream_ips
        iterator = datastream_ips

        content {
          name  = "datastream_ips-${datastream_ips.key}"
          value = datastream_ips.value
        }
      }
    }

    database_flags {
      name  = "max_allowed_packet"
      value = "1073741824"
    }
  }

  depends_on = [google_service_networking_connection.private_service_connection]
}

resource "google_sql_database" "sample_db" {
  instance = google_sql_database_instance.cloud_sql.id
  name     = "sample"
}

resource "random_password" "db_password" {
  length  = 16
  special = false
  numeric = false
}

resource "google_sql_user" "user" {
    name     = "user"
    instance = google_sql_database_instance.cloud_sql.id
    host     = "%"
    password = random_password.db_password.result
}

resource "null_resource" "create_db" {
    provisioner "local-exec" {
        working_dir = "${path.module}/sql/"
        command = "/bin/bash load_schema.sh ${var.project_id} ${google_sql_database_instance.cloud_sql.name}"
    }
}