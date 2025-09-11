# Copyright 2025 Google LLC
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

locals {
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "click-to-deploy-solutions"
    solution    = "editing-using-imagen"
    terraform   = "true"
  })

  editing_api_container = "us-central1-docker.pkg.dev/${var.project_id}/docker-repo/editing-using-imagen:${var.editing-using-imagen_tag}"
  function_name        = "editing-api"
}

variable "editing-using-imagen_tag" {
  description = "Editing API container tag"
  default     = "latest"
}

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "region" {
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