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

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = var.cluster_name
      subnet_ip             = var.cluster_ip_ranges.nodes
      subnet_region         = var.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    "${var.cluster_name}" = [
      {
        range_name    = "pods"
        ip_cidr_range = var.cluster_ip_ranges.pods
      },
      {
        range_name    = "services"
        ip_cidr_range = var.cluster_ip_ranges.services
      },
    ]
  }
}

resource "google_compute_router" "nat_router" {
  name    = "${module.vpc.network_name}-nat-router"
  network = module.vpc.network_self_link
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "${module.vpc.network_name}-nat-gw"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


# Firewall for nginx
# https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules
resource "google_compute_firewall" "nginx_admission" {
  name        = "${var.cluster_name}-master-to-worker"
  network     = module.vpc.network_self_link
  description = "Creates a nginx firewall rule from master to workers"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8443", "10254"]
  }

  source_ranges = [var.cluster_ip_ranges.master]
  target_tags   = [var.cluster_name]
}


resource "google_compute_firewall" "allow_ssh_iap" {
  name        = "${var.cluster_name}-allow-ssh-iap"
  network     = module.vpc.network_self_link
  description = "Allow SSH from IAP to VMs"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = [var.cluster_name]
}
