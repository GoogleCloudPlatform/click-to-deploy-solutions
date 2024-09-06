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

output "instance_endpoints" {
  description = "Map of instance name -> internal runtime endpoint IP address"
  value = tomap({
    for name, instance in module.apigee.instances : instance.name => instance.host
  })
}

output "instance_service_attachments" {
  description = "Map of instance region -> instance PSC service attachment"
  value = tomap({
    for name, instance in module.apigee.instances : instance.location => instance.service_attachment
  })
}

output "instance_map" {
  description = "Map of instance region -> instance object"
  value = tomap({
    for name, instance in module.apigee.instances : instance.location => instance
  })
}

output "org_id" {
  description = "Apigee Organization ID in the format of 'organizations/<org_id>'"
  value       = module.apigee.org_id
}

output "organization" {
  description = "Apigee Organization."
  value       = module.apigee.organization
}

output "environments" {
  description = "Apigee Environments"
  value       = module.apigee.environments
}

output "envgroups" {
  description = "Apigee Environment Groups"
  value       = module.apigee.envgroups
}