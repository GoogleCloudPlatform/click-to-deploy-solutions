resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/cloud-run-source-deploy/theimage:latest"
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

resource "google_cloud_run_service_iam_binding" "default" {
  location = google_cloud_run_v2_service.default.location
  service  = google_cloud_run_v2_service.default.name
  project  = var.project_id
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

# resource "null_resource" "public_access" {
#   provisioner "local-exec" {
#     command = <<-EOT
#       gcloud run services add-iam-policy-binding ${google_cloud_run_service.default.name} \
#         --member=allUsers --role=roles/run.invoker \
#         --project=${google_cloud_run_service.default.project} \
#         --region=${google_cloud_run_service.default.location}
#     EOT
#   }
# }

# TODO
# resource "google_project_iam_member" "cloud_run_vertex_ai_user" {
#   project = var.project_id  # Your project ID
#   role    = "roles/aiplatform.user"
#   member  = "serviceAccount:332904768527-compute@developer.gserviceaccount.com"
# }
