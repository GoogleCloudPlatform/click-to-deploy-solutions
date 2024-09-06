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
  description = "Project id."
  type        = string
}

variable "backend_migs" {
  description = "List of MIGs to be used as backends."
  type        = list(string)
}

variable "ssl_certificate" {
  description = "A list of SSL certificates for the HTTPS LB."
  type        = list(string)
}

variable "external_ip" {
  description = "(Optional) External IP for the L7 XLB."
  type        = string
  default     = null
}

variable "name" {
  description = "External LB name."
  type        = string
}

variable "security_policy" {
  description = "(Optional) The security policy associated with this backend service."
  type        = string
  default     = null
}

variable "edge_security_policy" {
  description = "(Optional) The edge security policy associated with this backend service."
  type        = string
  default     = null
}

variable "logs_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable logging for the load balancer traffic served by this backend service."
}

variable "backend_timeout" {
  type        = number
  default     = 10
  description = "Backend timeout in seconds"
}

variable "logs_sample_rate" {
  default     = null
  type        = number
  description = <<-EOD
  This field can only be specified if logging is enabled for this backend service. 
  The value of the field must be in [0, 1]. 
  EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<-EOD
  An optional map of label key:value pairs to assign to the forwarding rule.
  Default is an empty map.
  EOD
}

variable "ssl_policy" {
  type        = string
  default     = null
  description = <<-EOD
  A reference to the SslPolicy resource that will be associated with the TargetHttpsProxy resource. 
  If not set, the TargetHttpsProxy resource will not have any SSL policy configured.
  EOD
}