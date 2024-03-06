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
    solution    = "cloud-composer-etl"
    terraform   = "true"
  })
}

# ID of the project in which you want to deploy the solution
# This can be modify during deplopyment ONLY as it is part of the guided deployment. Do not modify this on the terraform.tfvars.

variable "project_id" {
  description = "GCP Project ID"
}

#Defines the deployment region for cloud resources.
variable "region" {
  type        = string
  description = "GCP region"
}

#Assigns a label to provisioned cloud resources
variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}
