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

/*
  Purpose: Specifies the geographical location where cloud resources (e.g., virtual machines, databases) will be deployed.
  Considerations: Factors like network latency, data residency regulations, and cost may influence region selection.
*/
region = "southamerica-east1"

/*
  Purpose: Adds metadata to resources, aiding in organization and filtering.
  Common uses: Distinguishing environments (development, staging, production), tracking costs, or assigning ownership.
*/
resource_labels = {
  env = "sandbox"
}
