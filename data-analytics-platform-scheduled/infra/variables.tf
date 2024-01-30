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

locals {
  function_name = "gcs-to-bq-trigger"
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "click-to-deploy-solutions"
    solution    = "data-analytics-platform-scheduled"
    terraform   = "true"
  })
}

variable "project_id" {
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}
