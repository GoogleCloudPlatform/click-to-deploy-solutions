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

# In case of Shared VPC, grant IAM permissions

resource "google_project_iam_member" "gke_network_user" {
  count = var.create_vpc ? 0 : 1

  project = local.network_project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_sec_admin" {
  count = var.create_vpc ? 0 : 1

  project = local.network_project
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_host_admin" {
  count = var.create_vpc ? 0 : 1

  project = local.network_project
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "apis_network_user" {
  count = var.create_vpc ? 0 : 1

  project = local.network_project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${data.google_project.project.number}@cloudservices.gserviceaccount.com"
}
