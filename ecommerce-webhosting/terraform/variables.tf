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
    solution    = "ecommerce-web-hosting"
    terraform   = "true"
  })

  service_account = {
    email  = google_service_account.service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  application_name = "ecommerce"

  health_check = {
    check_interval_sec  = null
    timeout_sec         = null
    healthy_threshold   = null
    unhealthy_threshold = null
    request_path        = "/"
    port                = 80
    host                = null
    logging             = null
  }
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

variable "zone" {
  type        = string
  description = "GCP Zone"
}

variable "network_name" {
  type = string
  description = "VPC name"
}

variable "webapp_cidr" {
  type        = string
  description = "Webapp subnet cidr"
  default     = "10.0.0.0/24"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

variable "group1_region" {
  default = "us-west1"
}