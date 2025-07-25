

resource "google_storage_bucket" "video_bucket" {
 name          = "${var.project_id}-genmedia-bucket"
 location      =  var.location
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-service-account"
  display_name = "Service Account for Cloud Run"
  project      = var.project_id
}

resource "google_project_iam_member" "my_service_account_member" {
  project = var.project_id
  role    = "roles/aiplatform.expressUser"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

resource "google_cloud_run_v2_service" "default" {
  name     = "genmedia-app"
  location = "us-central1"
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false
  template {
    containers {
      image = "gcr.io/${var.project_id}/genmedia:latest"
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "GCP_REGION"
        value = var.gcp_region
      }
      env {
        name  = "GCS_BUCKET"
        value = google_storage_bucket.video_bucket.name
      }
    }    
  }   
}

resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}