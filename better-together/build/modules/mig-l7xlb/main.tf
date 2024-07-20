/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_health_check" "mig_lb_hc" {
  project = var.project_id
  name    = "${var.name}-hc"
  https_health_check {
    port         = "443"
    request_path = "/healthz/ingress"
  }
}

resource "google_compute_backend_service" "mig_backend" {
  project               = var.project_id
  name                  = "${var.name}-backend"
  port_name             = "https"
  protocol              = "HTTPS"
  timeout_sec           = var.backend_timeout
  health_checks         = [google_compute_health_check.mig_lb_hc.id]
  security_policy       = var.security_policy
  edge_security_policy  = var.edge_security_policy
  dynamic "backend" {
    for_each = var.backend_migs
    content {
      group = backend.value
    }
  }
  log_config {
    enable      = var.logs_enabled
    sample_rate = var.logs_sample_rate
  }
}

resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = var.name
  default_service = google_compute_backend_service.mig_backend.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  project          = var.project_id
  name             = "${var.name}-target-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = var.ssl_certificate
  ssl_policy       = var.ssl_policy
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project    = var.project_id
  name       = "${var.name}-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.id
  ip_address = var.external_ip != null ? var.external_ip : null
  port_range = "443"
  labels     = var.labels
}