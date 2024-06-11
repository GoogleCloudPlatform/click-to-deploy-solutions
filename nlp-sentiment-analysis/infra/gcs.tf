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

resource "google_storage_bucket" "doc_input" {
  name                        = "${var.project_id}-sentiment-analysis-input"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.resource_labels
}

# resource "google_storage_bucket" "doc_output" {
#   name                        = "${var.project_id}-sentiment-analysis"
#   location                    = var.region
#   uniform_bucket_level_access = true
#   force_destroy               = true
#   labels                      = local.resource_labels
# }


resource "google_storage_bucket" "doc_output" {
  name                        = "${var.project_id}-sentiment-analysis-output"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.resource_labels
}