/**
Copyright 2023 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

# Handle secrets
resource "google_secret_manager_secret" "sqlhost" {
  project = var.project_number
  replication {
    automatic = true
  }
  secret_id  = "sqlhost"
  depends_on = [google_project_service.api]
}

resource "google_secret_manager_secret_version" "sqlhost" {
  enabled     = true
  secret      = "projects/${var.project_number}/secrets/sqlhost"
  secret_data = google_sql_database_instance.cloud_sql.private_ip_address
  depends_on  = [google_project_service.api, google_sql_database_instance.cloud_sql, google_secret_manager_secret.sqlhost]
}