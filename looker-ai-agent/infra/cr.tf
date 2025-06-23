resource "google_cloud_run_v2_service" "default" {
  name     = "looker-agent"
  location = "us-central1"
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/cloud-run-source-deploy/looker-agent:latest"
      env {
        name  = "PROJECT"
        value = var.project_id
      }

      env {
        name  = "LOCATION"
        value = var.region
      }
    }
    
  }   
}

# resource "google_cloud_run_service_iam_binding" "default" {
#   location = google_cloud_run_v2_service.default.location
#   service  = google_cloud_run_v2_service.default.name
#   project  = var.project_id
#   role     = "roles/run.invoker"
#   members = [
#     "allUsers"
#   ]
# }

