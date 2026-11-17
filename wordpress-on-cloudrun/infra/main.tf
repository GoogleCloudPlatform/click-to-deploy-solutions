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

locals {
  all_principals_iam = [for k in var.principals : "user:${k}"]
  cloudsql_conf = {
    database_version = "MYSQL_8_0"
    tier             = "db-g1-small"
    db               = "wp-mysql"
    user             = "admin"
  }
  iam = {
    # CloudSQL
    "roles/cloudsql.admin"        = local.all_principals_iam
    "roles/cloudsql.client"       = local.all_principals_iam
    "roles/cloudsql.instanceUser" = local.all_principals_iam
    # common roles
    "roles/logging.admin"                  = local.all_principals_iam
    "roles/iam.serviceAccountUser"         = local.all_principals_iam
    "roles/iam.serviceAccountTokenCreator" = local.all_principals_iam
  }
  #connector = var.connector == null ? google_vpc_access_connector.connector.0.self_link : var.connector
  prefix    = "wordpress-on-cloudrun"
}

resource "random_password" "wp_password" {
  length = 8
}

resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "cr-wordpress"
  display_name = "Cloud Run WordPress Service Account"
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_secret_manager_secret" "wordpress_db_password" {
  project   = var.project_id
  secret_id = "wordpress-db-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "wordpress_db_password" {
  secret      = google_secret_manager_secret.wordpress_db_password.id
  secret_data = var.cloudsql_password == null ? module.cloudsql.user_passwords[local.cloudsql_conf.user] : var.cloudsql_password
}

resource "google_secret_manager_secret_iam_member" "wordpress_db_password_accessor" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.wordpress_db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

# create the Cloud Run service
module "cloud_run" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=v40.1.0"
  project_id      = var.project_id
  name            = "cr-wordpress"
  region          = var.region
  service_account = google_service_account.cloud_run.email

  containers = {
    wordpress = {
      image = var.wordpress_image
      ports = {
        http = {
          container_port = var.wordpress_port
          name           = "http1"
          protocol       = null
        }
      }
      # set up the database connection
      env = {
        "WORDPRESS_DB_HOST" : module.cloudsql.ip
        "WORDPRESS_DB_NAME" : local.cloudsql_conf.db
        "WORDPRESS_DB_USER" : local.cloudsql_conf.user
      }
      env_from_key = {
        "WORDPRESS_DB_PASSWORD" = {
          name = google_secret_manager_secret.wordpress_db_password.secret_id
          key  = "latest"
        }
      }
    }
  }

  iam = {
    "roles/run.invoker" : [var.cloud_run_invoker]
  }

  revision_annotations = {
    autoscaling = {
      min_scale = 1
      max_scale = 2
    }
    # connect to CloudSQL
    cloudsql_instances  = [module.cloudsql.connection_name]
    #vpcaccess_connector = null
    # allow all traffic
    #vpcaccess_egress    = "all-traffic"
    #vpcaccess_connector = local.connector
  }
  ingress_settings = "all"

  depends_on = [
    google_secret_manager_secret_version.wordpress_db_password,
    google_secret_manager_secret_iam_member.wordpress_db_password_accessor,
    google_project_iam_member.cloudsql_client,
  ]
}
