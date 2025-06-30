data "google_secret_manager_secret_version" "looker_agent_secret_config_version" {
  provider = google-beta
  project  = var.project_id
  secret   = "LOOKER_AGENT_CONFIG"
  version  = "latest" 
}


resource "google_cloud_run_v2_service" "default" {
  name     = "looker-agent"
  location = "us-central1"
  project  = var.project_id
  ingress  = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false
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
      env {
        name = "LOOKER_AGENT_CONFIG"
        value_source {
          secret_key_ref {            
            secret  = data.google_secret_manager_secret_version.looker_agent_secret_config_version.secret            
            version = data.google_secret_manager_secret_version.looker_agent_secret_config_version.version
          }
        }
      }
    }    
  }   
}

# data "google_project" "project" {}

# # This resource grants the "Cloud Run Invoker" role to the Dialogflow service account
# resource "google_project_iam_member" "dialogflow_run_invoker" {
#   project = data.google_project.project.project_id
#   role    = "roles/run.invoker"
#   member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-dialogflow.iam.gserviceaccount.com"
# }

