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

# Firewall for nginx
# https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters#add_firewall_rules
resource "google_compute_firewall" "nginx_admission" {
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


resource "google_compute_firewall" "allow_ssh_iap" {
  count = var.create_vpc ? 1 : 0
  
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
