locals {
  resource_labels = {
    terraform = "true"
    app       = "ingest-api"
    env       = "sandbox"
    repo      = "gcp-streaming-data"
  }

  ingest_api_container = "us-central1-docker.pkg.dev/${var.project_id}/docker-repo/gcp-ingest-api:${var.ingest_api_tag}"
}

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-east1"
}

variable "ingest_api_tag" {
  description = "Ingest API container tag"
  default     = "latest"
}
