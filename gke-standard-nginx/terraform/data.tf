data "google_compute_network" "vpc" {
  name    = var.network_name
  project = local.network_project
}
