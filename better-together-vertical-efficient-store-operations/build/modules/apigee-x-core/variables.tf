/**
 * Copyright 2021 Google LLC
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
  description = "Project id (also used for the Apigee Organization)."
  type        = string
}

variable "org_display_name" {
  description = "Apigee org display name"
  type        = string
  default     = null
}

variable "org_description" {
  description = "Apigee org description"
  type        = string
  default     = "Apigee org created in TF"
}

variable "ax_region" {
  description = "GCP region for storing Apigee analytics data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

variable "network" {
  description = "Network (self-link) to peer with the Apigee tennant project."
  type        = string
}

variable "billing_type" {
  description = "Billing type of the Apigee organization."
  type        = string
  default     = null
}

variable "apigee_envgroups" {
  description = "Apigee Environment Groups."
  type = map(object({
    hostnames = list(string)
  }))
  default = {}
}

variable "apigee_environments" {
  description = "Apigee Environments."
  type = map(object({
    display_name = optional(string)
    description  = optional(string, "Terraform-managed")
    node_config = optional(object({
      min_node_count = optional(number)
      max_node_count = optional(number)
    }))
    iam       = optional(map(list(string)))
    type      = optional(string)
    envgroups = list(string)
  }))
  default = null
}

variable "apigee_instances" {
  description = "Apigee Instances (only one instance for EVAL)."
  type = map(object({
    region               = string
    ip_range             = string
    environments         = list(string)
    keyring_create       = optional(bool, true)
    keyring_name         = optional(string, null)
    keyring_location     = optional(string, null)
    key_name             = optional(string, "inst-disk")
    key_rotation_period  = optional(string, "2592000s")
    key_labels           = optional(map(string), null)
    consumer_accept_list = optional(list(string), null)
  }))
  default = {}
}

variable "org_key_rotation_period" {
  description = "Rotaton period for the organization DB encryption key"
  type        = string
  default     = "2592000s"
}

variable "org_kms_keyring_name" {
  description = "Name of the KMS Key Ring for Apigee Organization DB."
  type        = string
  default     = "apigee-x-org"
}

variable "org_kms_keyring_location" {
  description = "Location of the KMS Key Ring for Apigee Organization DB. Matches AX region if not provided."
  type        = string
  default     = null
}

variable "org_kms_keyring_create" {
  description = "Set to false to manage the keyring for the Apigee Organization DB and IAM bindings in an existing keyring."
  type        = bool
  default     = true
}
