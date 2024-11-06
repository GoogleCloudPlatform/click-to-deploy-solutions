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
data "google_project" "project" {}

locals {
  all_principals_iam = [for k in var.principals : "user:${k}"]
  cloudsql_conf = {
    database_version = "MYSQL_8_0"
    tier             = "db-g1-small"
    db               = "wp-mysql"
  }
  
  #connector = var.connector == null ? google_vpc_access_connector.connector.0.self_link : var.connector
  prefix    = "wordpress-on-cloudrun"
}

resource "random_password" "wp_password" {
  length = 8
}

resource "google_cloud_run_v2_service" "default" {
  provider = google-beta
  name     = "cr-wordpress"
  location = var.region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = var.wordpress_image
      ports {
        container_port = var.wordpress_port
      }

      env {
        name = "WORDPRESS_DB_HOST"
        value = "${google_sql_database_instance.cloud_sql.ip_address.0.ip_address}:3306"
      }
      env {
        name = "WORDPRESS_DB_NAME"
        value = local.cloudsql_conf.db
      }
      env {
        name = "WORDPRESS_DB_USER"
        value = "wp-user"
      }
      env {
        name = "WORDPRESS_DB_PASSWORD"
        value = random_password.cloudsql_password.result
      }
      env {
        name = "WORDPRESS_DEBUG"
        value = 1
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.cloud_sql.connection_name]
      }
    }
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location    = google_cloud_run_v2_service.default.location
  project     = google_cloud_run_v2_service.default.project
  service     = google_cloud_run_v2_service.default.name

  policy_data = jsonencode({
    bindings = [
      {
        role    = "roles/run.invoker"
        members = ["allUsers"]
      },
    ]
  })
}
