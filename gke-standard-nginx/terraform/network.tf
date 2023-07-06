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

resource "google_compute_network" "vpc" {
  count                   = var.create_vpc ? 1 : 0
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_router" "nat_router" {
  count = var.create_vpc ? 1 : 0

  name    = "${var.network_name}-nat-router"
  network = local.network_id
  region  = var.region

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_gateway" {
  count = var.create_vpc ? 1 : 0

  name                               = "${var.network_name}-nat-gw"
  router                             = google_compute_router.nat_router[0].name
  region                             = google_compute_router.nat_router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_subnetwork" "gke_subnet" {
  project = local.network_project

  name                     = var.cluster_name
  ip_cidr_range            = var.cluster_ip_ranges.nodes
  region                   = var.region
  network                  = local.network_id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.cluster_ip_ranges.pods
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.cluster_ip_ranges.services
  }
}

resource "google_compute_firewall" "nginx_admission" {
  project = local.network_project

  name        = "${var.cluster_name}-master-to-worker"
  network     = local.network_id
  description = "Creates a nginx firewall rule from master to workers"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8443", "10254"]
  }

  source_ranges = [var.cluster_ip_ranges.master]
  target_tags   = [var.cluster_name]
}

# resource "google_compute_firewall" "gke_internal" {
#   project = local.network_project

#   name        = "${var.cluster_name}-internal"
#   network     = local.network_id
#   description = "Communication between pods, nodes and services"

#   allow {
#     protocol = "tcp"
#   }

#   allow {
#     protocol = "udp"
#   }

#   source_ranges = [var.cluster_ip_ranges.pods, var.cluster_ip_ranges.services, var.cluster_ip_ranges.nodes]
#   target_tags   = [var.cluster_name]
# }

resource "google_compute_firewall" "allow_ssh_iap" {
  project = local.network_project

  name        = "${var.cluster_name}-allow-ssh-iap"
  network     = local.network_id
  description = "Allow SSH from IAP to VMs"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = [var.cluster_name]
}
