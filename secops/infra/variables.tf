variable org_id {
  type = string
  default = "506381943706"
  description = "The GCP Organization ID."
}

variable "project" {
  default = "charles-sec"
  type = string
  description = "The GCP Project ID."
}

###########################################
# WIF
###########################################

variable "saml_metadata" {
  type = string
  description = "The SAML Metadata of the IDP application. Should be a flattened XML string, with quotes escaped."
}

# IDP Groups to be mapped into WIF and GCP IAM
variable "admin_group" {
  type        = string
  description = "The IDP Group ID mapped to the default chronicle.admin role"
  default     = "secops_admin" 
}

variable "editor_group" {
  type        = string
  description = "The IDP Group ID mapped to the default chronicle.editor role"
  default     = "secops_editor"
}

variable "viewer_group" {
  type        = string
  description = "The IDP Group ID mapped to the default chronicle.viewer role"
  default     = "secops_viewer"
}

# Workforce Identity Federation : Pool
variable "workforce_pool_display_name" {
  type = string
  description = "The Workforce Pool Display Name"
  default     =  "Workforce Pool for Google SecOps"
}

variable "workforce_pool_description" {
  type = string
  description = "The Workforce Pool Description" 
  default     = "Workforce Pool for Google SecOps"
}

variable "workforce_pool_session_duration" {
  type = string
  description = "The Workforce Pool session duration.  Must be greater than 15 minutes, and less than 12 hours." 
  default     = "43200s" #12 Hours
}

# Workforce Identity Provider Pool
variable "workforce_pool_provider_display_name" {
  type = string
  description = "The Workforce Pool Provider display name." 
  default     = "Pool Provider for Google SecOps" 
}

variable "workforce_pool_provider_description" {
  type = string
  description = "The Workforce Pool Provider description." 
  default     = "Pool Provider for Google SecOps" 
}
