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

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "todo_dataset"
  friendly_name               = "todo"
  description                 = "Todo Dataset Demo"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "todo"
  deletion_protection = false # not recommended for PROD

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "title",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The Title"
  },
  {
    "name": "updated",
    "type": "DATETIME",
    "mode": "NULLABLE",
    "description": "Updated Date"
  },
  {
    "name": "completed",
    "type": "DATETIME",
    "mode": "NULLABLE",
    "description": "Completed Date"
  }
]
EOF

}