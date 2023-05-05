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

resource "google_bigquery_dataset" "ecommerce" {
  dataset_id  = "ecommerce"
  description = "Store ecommerce data"
  location    = var.region
  labels      = local.resource_labels
}

resource "google_bigquery_table" "order_events" {
  dataset_id          = google_bigquery_dataset.ecommerce.dataset_id
  table_id            = "order_events"
  description         = "Store order events"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "action_time"
  }

  labels = local.resource_labels

  schema = <<EOF
[
  {
    "name": "order_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "customer_email",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "action",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "action_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  }
]
EOF

}

resource "google_bigquery_data_transfer_config" "gcs_load" {
  display_name           = "load-order-events-from-gcs-to-bq"
  location               = var.region
  data_source_id         = "google_cloud_storage"
  schedule               = "every 15 minutes"
  destination_dataset_id = google_bigquery_dataset.ecommerce.dataset_id
  params = {
    # destination
    destination_table_name_template = "order_events"
    write_disposition               = "APPEND"

    # source
    data_path_template    = "gs://${google_storage_bucket.upload_bucket.name}/order-events/*.csv"
    file_format           = "CSV"
    max_bad_records       = "1"
    ignore_unknown_values = "true"
    field_delimiter       = ","
    quote                 = ";"
    skip_leading_rows     = "1"
    allow_quoted_newlines = "true"
    allow_jagged_rows     = "false"
    delete_source_files   = "false"
  }

}
