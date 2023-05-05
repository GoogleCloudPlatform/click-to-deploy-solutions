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

resource "google_storage_bucket" "gcf_source_bucket" {
  name                        = "${var.project_id}-gcf-source-bucket"
  location                    = var.region
  uniform_bucket_level_access = true
  labels                      = local.resource_labels
}

resource "google_storage_bucket_object" "gcf_source_code" {
  name   = "function-source-${formatdate("YYYYMMDDhhmmss", timestamp())}.zip"
  bucket = google_storage_bucket.gcf_source_bucket.name
  source = "/workspace/function-source.zip"
}

resource "google_cloudfunctions2_function" "function" {
  name        = local.function_name
  location    = var.region
  description = "Trigger Cloud Vision API for Object Localization"
  labels      = local.resource_labels

  build_config {
    runtime     = "python310"
    entry_point = "trigger_gcs" # Set the entry point in the code

    source {
      storage_source {
        bucket = google_storage_bucket.gcf_source_bucket.name
        object = google_storage_bucket_object.gcf_source_code.name
      }
    }
  }

  service_config {
    max_instance_count    = 3
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.obj_detect_function.email
    environment_variables = {
      BQ_TABLE_ID      = local.bq_table_id
      BQ_LOCATION      = var.region
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.images.name
    }
  }

  depends_on = [
    google_project_iam_member.event_receiver,
    google_project_iam_member.gcs_to_pubsub
  ]
}

data "google_cloud_run_service" "run_service" {
  name     = google_cloudfunctions2_function.function.name
  location = var.region
}

resource "google_cloud_run_service_iam_member" "run_service_member" {
  location = data.google_cloud_run_service.run_service.location
  service  = data.google_cloud_run_service.run_service.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
