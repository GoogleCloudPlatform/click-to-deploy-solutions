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

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp-from-iap"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-rdp"]
}
