# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "gce-lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google"
  version = "~> 6.2"

  project           = var.project_id
  name              = "${var.application_name}-lb"
  target_tags       = ["allow-health-check"]
  firewall_networks = [module.vpc.network_name]

  backends = {
    default = {
      description             = null
      protocol                = "HTTP"
      port                    = 80
      port_name               = "http"
      timeout_sec             = 10
      enable_cdn              = true
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = google_compute_security_policy.policy.name

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}
