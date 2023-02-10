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

resource "google_datastream_connection_profile" "source_connection_profile" {
    display_name          = "Source connection profile"
    location              = var.region
    connection_profile_id = "source-profile"

    mysql_profile {
        hostname = google_sql_database_instance.cloud_sql.public_ip_address
        username = google_sql_user.user.name
        password = random_password.db_password.result
    }
}

resource "google_datastream_connection_profile" "destination_connection_profile" {
    display_name          = "Destination Connection profile"
    location              = var.region
    connection_profile_id = "destination-profile"

    bigquery_profile {}
}

resource "google_datastream_stream" "default" {
    stream_id = "my-stream"
    location = var.region
    display_name = "my stream"
    source_config {
        source_connection_profile = google_datastream_connection_profile.source_connection_profile.id
        mysql_source_config {
            include_objects {
                mysql_databases {
                    database = "todo"
                }
            }
        }
    }
    destination_config {
        destination_connection_profile = google_datastream_connection_profile.destination_connection_profile.id
        bigquery_destination_config {
            single_target_dataset {
                dataset_id = "${var.project_id}:todo_dataset"
            } 
        }
    }

    backfill_all {
    }

    depends_on = [google_sql_database_instance.cloud_sql]
}