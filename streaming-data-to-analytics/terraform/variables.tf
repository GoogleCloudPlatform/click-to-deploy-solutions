locals {
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "click-to-deploy-solutions"
    solution    = "streaming-data-to-analytics"
    terraform   = "true"
    }
  )

  ingest_api_container = "us-central1-docker.pkg.dev/${var.project_id}/docker-repo/gcp-ingest-api:${var.ingest_api_tag}"
  function_name        = "ingest-api"
}

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "ingest_api_tag" {
  description = "Ingest API container tag"
  default     = "latest"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}
