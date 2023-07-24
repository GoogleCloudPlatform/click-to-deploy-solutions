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

resource "google_bigquery_dataset" "aiml_dataset" {
  dataset_id = local.bq_dataset_name
  location   = var.region
  labels     = local.resource_labels
}

resource "google_bigquery_table" "object_localization" {
  dataset_id          = google_bigquery_dataset.aiml_dataset.dataset_id
  table_id            = local.bq_table_name
  description         = "Store object localization results"
  deletion_protection = false
  labels              = local.resource_labels

  schema = <<EOF
[
  {
    "name": "file_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "objects",
    "type": "JSON",
    "mode": "NULLABLE"
  }
]
EOF
}

resource "google_bigquery_data_transfer_config" "gcs_load" {
  display_name           = "object-localization-gcs-to-bq"
  location               = var.region
  data_source_id         = "google_cloud_storage"
  schedule               = "every 15 minutes"
  destination_dataset_id = google_bigquery_dataset.aiml_dataset.dataset_id
  params = {
    # destination
    destination_table_name_template = local.bq_table_name
    write_disposition               = "APPEND"

    # source
    data_path_template    = "gs://${google_storage_bucket.images_output.name}/*.json"
    file_format           = "JSON"
    max_bad_records       = "1"
    ignore_unknown_values = "true"
    delete_source_files   = "true"
  }

  depends_on = [
    google_project_iam_member.bq_transfer_iam
  ]
}
