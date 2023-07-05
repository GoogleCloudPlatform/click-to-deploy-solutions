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

data "google_project" "project" {}

locals {
  resource_labels = {
    app         = var.application_name
    deployed_by = "cloudbuild"
    env         = "sandbox"
    repo        = "click-to-deploy-solutions"
    solution    = "gke-autopilot-hpa"
    terraform   = "true"
  }

  service_account = {
    email  = google_service_account.service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

variable "application_name" {
  description = "Application name"
  default     = "web-app-example"
}

variable "network_name" {
  type        = string
  description = "VPC name"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR"
}
