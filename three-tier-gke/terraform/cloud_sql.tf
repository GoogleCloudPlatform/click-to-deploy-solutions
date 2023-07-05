/**
Copyright 2023 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

resource "random_id" "id" {
  byte_length = 2
}

resource "google_sql_database_instance" "cloud_sql" {
  name             = "${var.application_name}-db-${random_id.id.hex}"
  database_version = "MYSQL_5_7"
  region           = var.region
  project          = var.project_id
  settings {
    tier                  = "db-g1-small"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"

    ip_configuration {
      ipv4_enabled    = false
      private_network = module.vpc.network_self_link
    }
  }
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.service_networking,
    google_project_service.api
  ]
}

resource "null_resource" "create_db" {
  provisioner "local-exec" {
    working_dir = "${path.module}/code/database"
    command     = "/bin/bash load_schema.sh ${var.project_id} ${google_sql_database_instance.cloud_sql.name}"
  }
}