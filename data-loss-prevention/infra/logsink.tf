resource "google_logging_project_sink" "logrouter" {
  name                   = "logrouter-pubsub"
  project                = var.project_id
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.pubsub_topic.id}"
  filter                 = "resource.type=cloud_run_revision AND resource.labels.service_name=generate-service AND textPayload=~\"\\{'name': '(.*?)', 'email': '(.*?)', 'address': '(.*?)', 'phone_number': '(.*?)', 'ssn': '(.*?)', 'credit_card_number': '(.*?)'\\}\""
  unique_writer_identity = true

  depends_on = [ google_pubsub_topic.pubsub_topic ]
}

resource "google_service_account" "pubsub-invoker-sa" {
  account_id   = "tf-pubsub-invoker-sa"
  display_name = "Service Account For Pub/Sub invoke Cloud Run"
  project      = var.project_id
}

resource "google_project_iam_member" "token-creator-role" {
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.pubsub-invoker-sa.email}"
  project = var.project_id
}

resource "google_project_iam_member" "run-invoke-role" {
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.pubsub-invoker-sa.email}"
  project = var.project_id
}

resource "google_pubsub_topic" "pubsub_topic" {
  name    = "pubsub-topic-logrouter"
  project = var.project_id
  labels  = local.resource_labels
}

resource "google_pubsub_subscription" "pubsub_subscription" {
  name   = "pubsub-subscription-logrouter"
  project = var.project_id
  topic  = google_pubsub_topic.pubsub_topic.id
  labels = local.resource_labels

  push_config {
    push_endpoint = var.redact_service
    oidc_token {
      service_account_email = google_service_account.pubsub-invoker-sa.email
    }
  }
}
