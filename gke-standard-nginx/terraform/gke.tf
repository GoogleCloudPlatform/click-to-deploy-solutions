# Copyright 2022 Google LLC
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

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version    = "21.1.0"
  project_id = var.project_id
  region     = var.region
  name       = var.cluster_name

  network                   = module.vpc.network_name
  subnetwork                = var.cluster_name
  ip_range_pods             = "pods"
  ip_range_services         = "services"
  http_load_balancing       = false
  network_policy            = false
  default_max_pods_per_node = 32

  // Private cluster setup
  enable_private_nodes   = true
  master_ipv4_cidr_block = var.cluster_ip_ranges.master

  // allowlist who can reach cluster's master nodes
  // NOTE: internet is not recommended! It is used for testing only.
  master_authorized_networks = [
    {
      display_name = "internet"
      cidr_block   = "0.0.0.0/0"
    }
  ]

  cluster_resource_labels  = local.resource_labels
  release_channel          = "STABLE"
  create_service_account   = true
  remove_default_node_pool = true
  enable_shielded_nodes    = true

  node_pools = [
    {
      name               = "base"
      machine_type       = "e2-standard-2"
      min_count          = 1
      max_count          = 5
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      enable_secure_boot = true
    },
  ]

  node_pools_tags = {
    all = [
      var.cluster_name
    ]
  }

  depends_on = [
    module.vpc
  ]
}
