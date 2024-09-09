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

resource "google_storage_bucket" "audio-analysis" {
  name                        = "${var.project_id}-audio-analysis"
  force_destroy               = true
  labels                      = local.resource_labels
  location                    = var.function_location
  uniform_bucket_level_access = true
  project                     = var.project_id
}

resource "google_storage_bucket_object" "function-source" {
  name   = "generate_audio_transcript_py.zip"
  bucket = google_storage_bucket.audio-analysis.name
  source = "../helpers/generate_audio_transcript_py.zip"
}


module "cloud_functions2" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "0.5"

  project_id        = var.project_id
  function_name     = "generate_audio_transcript"
  function_location = var.function_location
  runtime           = "python38"
  entrypoint        = "generate_audio_transcript"
  build_env_variables = {
    PROJECT_ID = var.project_id
    LOCATION = var.function_location
    BUCKET = var.gcs_dataset_location
  }
  storage_source = {
    bucket     = google_storage_bucket.audio-analysis.name
    object     = google_storage_bucket_object.function-source.name
    generation = null
  }
}