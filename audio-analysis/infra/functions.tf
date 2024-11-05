#  * Copyright 2024 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.

resource "google_storage_bucket" "gcf_source_bucket" {
  name                        = "${var.project_id}-gcf-source-bucket"
  location                    = var.region
  uniform_bucket_level_access = true
  labels                      = local.resource_labels
  force_destroy               = false
}

resource "google_storage_bucket_object" "gcf_source_code" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.gcf_source_bucket.name
  source = "/workspace/function-source.zip"
}

resource "google_cloudfunctions2_function" "function" {
  name        = local.function_name
  location    = var.region
  description = "Trigger NLP when an object is placed into input bucket"
  labels      = local.resource_labels

  build_config {
    runtime     = "python310"
    entry_point = "transcribeAndMask" # Set the entry point in the code

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
    available_memory      = "1Gi"
    timeout_seconds       = 60
    service_account_email = data.google_compute_default_service_account.default.email
    environment_variables = {
      GCS_OUTPUT_BUCKET = google_storage_bucket.audio_analysis_output.name
      GCS_INPUT_BUCKET  = google_storage_bucket.audio_analysis_input.name
      GCP_PROJECT       = var.project_id
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.storage.object.v1.finalized"
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    event_filters {
      attribute = "bucket"
      value     = google_storage_bucket.audio_analysis_input.name
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
  member   = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}