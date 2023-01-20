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

locals {
  sql_instance_name = "${var.sql_instance_prefix}-${random_id.db_name_suffix.hex}"
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    env         = "sandbox"
    repo        = "click-to-deploy-solutions"
    solution    = "private-cloud-data-fusion"
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

variable "network_name" {
  type        = string
  description = "VPC name"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

variable "service_networking_cidr" {
  type        = string
  description = "CIDR /18 for the Service Networking without the /XX"
  default     = "10.200.0.0"
}

variable "cdf_cidr" {
  type        = string
  description = "Cloud Data Fusion CIDR /22 without the /XX"
  default     = "10.124.40.0"
}

variable "cdf_instance_name" {
  type        = string
  description = "Cloud Data Fusion instance name"
  default     = "cdf-private"
}

variable "sql_instance_prefix" {
  type        = string
  description = "Cloud SQL instance prefix"
  default     = "mysql"
}
