resource "google_service_account" "ingest_api" {
  account_id   = local.function_name
  display_name = "Cloud Function Ingest API"
}

resource "google_project_iam_member" "publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.ingest_api.email}"
}

resource "google_project_iam_member" "pubsub_to_bq" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}
