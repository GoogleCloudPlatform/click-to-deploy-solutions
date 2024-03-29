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

resource "google_compute_backend_bucket" "assets" {
  name        = "ecommerce-${var.project_id}"
  description = "Contains static resources for example app"
  bucket_name = google_storage_bucket.assets.name
  enable_cdn  = true
}

resource "google_storage_bucket" "assets" {
  name                        = "ecommerce-${var.project_id}"
  location                    = "US"
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.resource_labels
}

resource "google_storage_bucket_object" "style" {
  name         = "assets/css/style.css"
  content      = file(format("%s./code/style.css", path.module))
  content_type = "text/css"
  bucket       = google_storage_bucket.assets.name
}

resource "google_storage_bucket_object" "style_prefix" {
  name         = "assets/css/style-prefix.css"
  content      = file(format("%s./code/style-prefix.css", path.module))
  content_type = "text/css"
  bucket       = google_storage_bucket.assets.name
}

resource "google_storage_bucket_object" "script" {
  name         = "assets/js/script.js"
  content      = file(format("%s./code/script.js", path.module))
  content_type = "text/javascript"
  bucket       = google_storage_bucket.assets.name
}

resource "google_storage_bucket_iam_member" "public_bucket_iam" {
  bucket   = google_storage_bucket.assets.name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}
