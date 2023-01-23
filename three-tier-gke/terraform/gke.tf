/**
Copyright 2023 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

resource "google_container_cluster" "primary" {
  name             = local.cluster_name
  location         = var.region
  resource_labels  = local.resource_labels
  enable_autopilot = true

  release_channel {
    channel = "STABLE"
  }

  # networking
  network    = module.vpc.network_name
  subnetwork = "subnet-${var.region}"
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  // allow list who can reach cluster's master nodes
  // NOTE: internet is not recommended! It is used for testing only.
  master_authorized_networks_config {
    cidr_blocks {
      display_name = "internet"
      cidr_block   = "0.0.0.0/0"
    }
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = local.cluster_ip_ranges.master
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  depends_on = [
    module.vpc,
    //google_sql_database_instance.cloud_sql
  ]
}

resource "null_resource" "create_namespace" {
  provisioner "local-exec" {
    working_dir = "${path.module}/code/yaml"
    command     = "gcloud builds submit ."
  }

  depends_on = [
    google_container_cluster.primary
  ]
}