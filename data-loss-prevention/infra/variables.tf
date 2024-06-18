locals {
  resource_labels = merge(var.resource_labels, {
    deployed_by = "cloudbuild"
    repo        = "click-to-deploy-solutions"
    solution    = "dlp"
    terraform   = "true"
  })
}

variable "project_id" {
  description = "GCP Project ID"
  default     = null
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "location" {
  type        = string
  description = "GCP location"
}

variable "resource_labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

variable "redact_service" {
  type        = string
  description = "Redact Service URL"
}
