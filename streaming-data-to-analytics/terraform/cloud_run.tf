resource "google_cloud_run_service" "default" {
  name     = "ingest-api"
  location = var.region

  template {
    spec {
      containers {
        image = var.gcp_ingest_api_image
        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "TOPIC_ID"
          value = google_pubsub_topic.ingest_api.name
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "1"
        "autoscaling.knative.dev/maxScale" = "10"
      }
      labels = local.resource_labels
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
