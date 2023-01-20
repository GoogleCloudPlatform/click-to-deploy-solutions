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

module "vpc" {
  source       = "terraform-google-modules/network/google//modules/vpc"
  version      = "~> 6.0"
  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"
}

# Create subnetes out of VPC module for a better terraform destroy order
resource "google_compute_subnetwork" "subnet" {
  name                     = "subnet-${var.region}"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  network                  = module.vpc.network_name
  private_ip_google_access = true
}


## Service Network ## 
resource "google_compute_global_address" "service_range" {
  name          = "servicenetworking-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.service_networking_cidr
  prefix_length = 16
  network       = module.vpc.network_name
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_compute_network_peering_routes_config" "private_service_connection" {
  peering              = google_service_networking_connection.private_service_connection.peering
  network              = module.vpc.network_name
  import_custom_routes = false
  export_custom_routes = true
}

## Nat ## 
resource "google_compute_router" "nat_router" {
  name    = "${module.vpc.network_name}-nat-router"
  network = module.vpc.network_self_link
  region  = var.region
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

## Firewall ## 
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-iap"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow_private_data_fusion" {
  name    = "allow-private-data-fusion"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22", "3306", "5432", "1433"]
  }

  source_ranges = [var.cdf_cidr]
}

# This rule is not recommended for production
resource "google_compute_firewall" "allow_all_internal" {
  name    = "allow-all-internal"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}
