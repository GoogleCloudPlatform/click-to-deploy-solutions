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

resource "google_data_fusion_instance" "cdf_private" {
  name                          = var.cdf_instance_name
  description                   = "Cloud Data Fusion private instance"
  region                        = var.region
  type                          = "DEVELOPER"
  version                       = "6.7.2"
  enable_stackdriver_logging    = true
  enable_stackdriver_monitoring = true
  labels                        = local.resource_labels
  private_instance              = true
  dataproc_service_account      = google_service_account.cdf_dataproc.email

  network_config {
    network       = module.vpc.network_name
    ip_allocation = "${var.cdf_cidr}/22"
  }

  depends_on = [
    google_compute_global_address.cdf
  ]
}

resource "google_compute_global_address" "cdf" {
  name          = "cdf-${var.region}-${var.cdf_instance_name}-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.cdf_cidr
  prefix_length = 22
  network       = module.vpc.network_name
}

resource "google_compute_network_peering" "cdf" {
  name                 = "cdf-${var.region}-${var.cdf_instance_name}-peering"
  network              = module.vpc.network_id
  peer_network         = "projects/${google_data_fusion_instance.cdf_private.tenant_project_id}/global/networks/${var.region}-${var.cdf_instance_name}"
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_service_account" "cdf_dataproc" {
  account_id   = "cdf-dataproc"
  display_name = "Service Account for Cloud Data Fusion Dataproc jobs"
}

resource "google_project_iam_member" "cdf_dataproc_admin" {
  project = var.project_id
  role    = "roles/dataproc.admin"
  member  = "serviceAccount:${google_service_account.cdf_dataproc.email}"
}
