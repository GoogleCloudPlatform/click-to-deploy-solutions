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
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "click-to-deploy-solutions"
    solution    = "object-localization"
    terraform   = "true"
  })
  
  function_name   = "object-localization"
  
  bq_table_name   = "object_localization"
  bq_dataset_name = "aiml"
  bq_table_id     = "${var.project_id}.${local.bq_dataset_name}.${local.bq_table_name}"
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
