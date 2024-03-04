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
  connector = var.connector == null ? google_vpc_access_connector.connector.0.self_link : var.connector
  prefix    = var.prefix == null ? "" : "${var.prefix}-"
}

# either create a project or set up the given one
module "project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v23.0.0"
  name            = var.project_id
  parent          = try(var.project_create.parent, null)
  billing_account = try(var.project_create.billing_account_id, null)
  project_create  = var.project_create != null
  prefix          = var.project_create == null ? null : var.prefix
  iam             = var.project_create != null ? local.iam : {}
  iam_additive    = var.project_create == null ? local.iam : {}
  services = [
    "run.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "sqladmin.googleapis.com",
    "sql-component.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

resource "random_password" "wp_password" {
  length = 8
}

# create the Cloud Run service
module "cloud_run" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/cloud-run?ref=v23.0.0"
  project_id = module.project.project_id
  name       = "${local.prefix}cr-wordpress"
  region     = var.region

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
        "WORDPRESS_DB_PASSWORD" : var.cloudsql_password == null ? module.cloudsql.user_passwords[local.cloudsql_conf.user] : var.cloudsql_password
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
    vpcaccess_connector = null
    # allow all traffic
    vpcaccess_egress    = "all-traffic"
    vpcaccess_connector = local.connector
  }
  ingress_settings = "all"
}
