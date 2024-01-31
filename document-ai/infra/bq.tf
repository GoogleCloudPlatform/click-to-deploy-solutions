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

resource "google_bigquery_dataset" "document_ai" {
  dataset_id  = "document_ai"
  description = "Store documents parsed by Document AI"
  location    = var.region
  labels      = local.resource_labels
}

resource "google_bigquery_table" "form_parser" {
  dataset_id          = google_bigquery_dataset.document_ai.dataset_id
  table_id            = "form_parser"
  description         = "Store form documents"
  deletion_protection = false
  labels              = local.resource_labels

  schema = <<EOF
[
  {
    "name": "document_file_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "document_content",
    "type": "JSON",
    "mode": "NULLABLE"
  },
  {
    "name": "document_summary",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF

}
