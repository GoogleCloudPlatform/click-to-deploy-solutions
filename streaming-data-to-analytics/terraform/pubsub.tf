resource "google_pubsub_topic" "ingest_api" {
  name   = "ingest-api"
  labels = local.resource_labels
}

resource "google_pubsub_subscription" "order_to_bq_sub" {
  name   = "order-event-to-bigquery"
  topic  = google_pubsub_topic.ingest_api.name
  labels = local.resource_labels
  filter = "attributes.entity=\"order-event\""

  bigquery_config {
    table          = "${data.google_project.project.name}.${google_bigquery_dataset.raw.dataset_id}.${google_bigquery_table.raw_order_events.table_id}"
    write_metadata = true
  }
  
  depends_on = [
    google_project_iam_member.pubsub_to_bq
  ]
}

resource "google_pubsub_subscription" "unknown_to_bq_sub" {
  name   = "unknown-to-bigquery"
  topic  = google_pubsub_topic.ingest_api.name
  labels = local.resource_labels
  filter = "attributes.entity=\"unknown\""

  bigquery_config {
    table          = "${data.google_project.project.name}.${google_bigquery_dataset.raw.dataset_id}.${google_bigquery_table.raw_order_events.table_id}"
    write_metadata = true
  }

  depends_on = [
    google_project_iam_member.pubsub_to_bq
  ]
}
