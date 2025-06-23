resource "google_cloud_run_service" "run_service" {
  name = local.function_name
  location = "us-central1"

  template {
    spec {
      containers {
        image = local.editing_api_container
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.run_service.name
  location = google_cloud_run_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}