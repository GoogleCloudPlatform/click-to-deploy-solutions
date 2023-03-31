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

resource "google_compute_attached_disk" "default" {
  disk     = google_compute_disk.default.id
  instance = google_compute_instance.default.id
}

resource "google_compute_instance" "default" {
  name         = "windows-fileserver"
  machine_type = "e2-standard-2"
  zone         = var.zone
  labels       = local.resource_labels

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-server-2022-dc-v20230315"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata_startup_script = "echo hi > /test.txt"
}

resource "google_compute_disk" "default" {
  name   = "disk"
  type   = "pd-ssd"
  zone   = "us-central1-a"
  size   = 2000
  labels = local.resource_labels
}

resource "google_compute_disk_resource_policy_attachment" "attachment" {
  name   = google_compute_resource_policy.policy.name
  disk   = google_compute_disk.default.name
  zone   = "us-central1-a"
}

resource "google_compute_resource_policy" "policy" {
  name   = "snapshot-policy"
  region = "us-central1"

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time = "00:00"
      }
    }
  }
}