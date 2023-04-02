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
      subnet_name           = "subnet-${var.region}"
      subnet_ip             = var.webapp_cidr
      subnet_region         = var.region
      subnet_private_access = true
    },
  ]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${module.vpc.network_name}-allow-ssh-from-iap"
  network = module.vpc.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "35.235.240.0/20"
  ]

  target_tags = [
    "allow-ssh"
  ]
}

resource "google_compute_global_address" "service_range" {
  name          = "service-networking-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.200.0.0"
  prefix_length = 16
  network       = module.vpc.network_name
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = module.vpc.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.service_range.name]
}