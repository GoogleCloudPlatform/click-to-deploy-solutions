/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "GCP Project ID"
}

variable "ax_region" {
  description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    hostnames = list(string)
  }))
  default = null
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL orgs)."
  type = map(object({
    region       = string
    ip_range     = string
    environments = list(string)
  }))
  default = null
}

variable "apigee_environments" {
  description = "Apigee Environments."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    node_config = optional(object({
      min_node_count = optional(number)
      max_node_count = optional(number)
    }))
    iam       = optional(map(list(string)))
    envgroups = list(string)
    type      = optional(string)
  }))
  default = null
}

variable "network" {
  description = "Name of the VPC network to peer with the Apigee tennant project."
  type        = string
}

variable "peering_range" {
  description = "Service Peering CIDR range."
  type        = string
}

variable "support_range" {
  description = "Support CIDR range of length /28 (required by Apigee for troubleshooting purposes)."
  type        = string
}