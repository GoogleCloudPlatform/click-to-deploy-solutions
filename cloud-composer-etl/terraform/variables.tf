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

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "composer_env_name" {
  type        = string
  description = "Cloud Composer environment name"
  default     = "composer-af2"
}

variable "composer_ip_ranges" {
  type        = map(string)
  description = "Composer 2 runs on GKE, so inform here the IP ranges you want to use"
  default = {
    pods     = "10.0.0.0/22"
    services = "10.0.4.0/24"
    nodes    = "10.0.6.0/24"
    master   = "10.0.7.0/28"
  }
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default = {
    deployed_by = "cloudbuild"
    env         = "sandbox"
    repo        = "click-to-deploy-solutions"
    solution    = "cloud-composer-etl"
    terraform   = "true"
  }
}
