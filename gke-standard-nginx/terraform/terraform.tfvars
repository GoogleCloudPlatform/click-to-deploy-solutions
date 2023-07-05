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

# Create a new VPC
create_vpc   = true
network_name = "vpc-gke-std"

# Use an existing Shared VPC
# create_vpc         = false
# network_name       = "syl-vpc-nonprod"
# network_project_id = "syl-network-359815"

region       = "southamerica-east1"
cluster_name = "gke-std-sandbox"
cluster_ip_ranges = {
  pods     = "10.1.0.0/22"
  services = "10.1.4.0/24"
  nodes    = "10.1.5.0/24"
  master   = "10.1.6.0/28"
}

resource_labels = {
  env = "sandbox"
}
