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
    repo        = "click-to-deploy-solutions"
    solution    = "genmedia"
    terraform   = "true"
  })
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "project_number" {
  description = "GCP Project Number"
}

variable "gcp_region" {
  type        = string
  description = "GCP region"
}

variable "location" {
  type        = string
  description = "GCP location"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

# Documentation: https://cloud.google.com/run/docs/securing/managing-access#making_a_service_public
variable "cloud_run_invoker" {
  type        = string
  description = "IAM member authorized to access the end-point (for example, 'user:YOUR_IAM_USER' for only you or 'allUsers' for everyone)"
  default     = "allUsers"
}
