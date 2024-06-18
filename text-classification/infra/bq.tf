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

resource "google_bigquery_dataset" "classified_messages" {
  dataset_id  = "classified_messages"
  project   = var.project_id
  description = "Stored the received messages with its classification"
  location    = var.region
}

resource "google_bigquery_table" "classified_messages_table" {
  dataset_id          = google_bigquery_dataset.classified_messages.dataset_id
  project             = var.project_id
  table_id            = "classified_messages"
  description         = "Store messages sent to message AI text classification"
  deletion_protection = false
  schema = jsonencode([
     {
      "name": "message",
      "type": "STRING",
      "mode": "REQUIRED"  
    },
    {
      "name": "emotion",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "timestamp",
      "type": "TIMESTAMP",
      "mode": "REQUIRED"
    }
  ])
}
