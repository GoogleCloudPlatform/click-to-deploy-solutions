/**
Copyright 2023 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


data "google_project" "project" {}

locals {
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    env         = "sandbox"
    repo        = "click-to-deploy-solutions"
    solution    = "three-tier-gke"
    terraform   = "true"
  })

  service_account = {
    email  = google_service_account.service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  cluster_name = "gke-autopilot-treetier"
  cluster_ip_ranges = {
    pods     = "10.0.0.0/22"
    services = "10.0.4.0/24"
    nodes    = "10.0.6.0/24"
    master   = "10.0.7.0/28"
  }
}

variable "application_name" {
  description = "Application name"
  default     = "tree-tier"
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "project_number" {
  description = "GCP Project Number"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "apis" {
  description = "APIs required to deploy the project"
  default     = ["redis.googleapis.com", "compute.googleapis.com", "sqladmin.googleapis.com", "secretmanager.googleapis.com", "servicenetworking.googleapis.com", "cloudbuild.googleapis.com", "cloudresourcemanager.googleapis.com"]
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}