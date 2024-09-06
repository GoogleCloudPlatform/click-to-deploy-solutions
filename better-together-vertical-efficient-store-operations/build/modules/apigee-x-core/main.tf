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

locals {
  envgroups = { for key, value in var.apigee_envgroups : key => value.hostnames }
  instances = { for key, value in var.apigee_instances : value.region => {
    name                  = key
    environments          = value.environments
    runtime_ip_cidr_range = value.ip_range
    disk_encryption_key   = module.kms-inst-disk[key].key_ids[value.key_name]
    consumer_accept_list  = value.consumer_accept_list
  } }
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "apigee.googleapis.com"
}

module "kms-org-db" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v28.0.0"
  project_id = var.project_id
  iam = {
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
  }
  keyring = {
    location = coalesce(var.org_kms_keyring_location, var.ax_region)
    name     = var.org_kms_keyring_name
  }
  keyring_create = var.org_kms_keyring_create
  keys = {
    org-db = { rotation_period = var.org_key_rotation_period, labels = null }
  }
}

module "kms-inst-disk" {
  for_each   = var.apigee_instances
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/kms?ref=v28.0.0"
  project_id = var.project_id
  iam = {
    "roles/cloudkms.cryptoKeyEncrypterDecrypter" = ["serviceAccount:${google_project_service_identity.apigee_sa.email}"]
  }
  keyring = {
    location = coalesce(each.value.keyring_location, each.value.region)
    name     = coalesce(each.value.keyring_name, "apigee-${each.key}")
  }
  keyring_create = each.value.keyring_create
  keys = {
    (each.value.key_name) = {
      rotation_period = each.value.key_rotation_period
      labels          = each.value.key_labels
    }
  }
}

module "apigee" {
  source     = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/apigee?ref=v28.0.0"
  project_id = var.project_id
  organization = {
    display_name            = var.org_display_name
    description             = var.org_description
    authorized_network      = var.network
    runtime_type            = "CLOUD"
    billing_type            = var.billing_type
    database_encryption_key = module.kms-org-db.key_ids["org-db"]
    analytics_region        = var.ax_region
  }
  envgroups    = local.envgroups
  environments = var.apigee_environments
  instances    = local.instances
}
