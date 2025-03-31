# Copyright 2023 Google LLC
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

terraform {
  backend "gcs" {
    # Note, you can't use a variable for the TF state itself
    bucket = "charles-sec-tf-state"
  }
}

provider "google" {
  project = "${var.project}"
}

resource "google_project_service" "chronicle" {
  project = var.project
  service = "chronicle.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project = var.project
  service = "iam.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}

##################################################


resource "google_iam_workforce_pool" "chronicle_pool" {
  workforce_pool_id = "pool-${var.project}"
  parent            = "organizations/${var.org_id}"
  location          = "global"
  display_name      = "${format("%.34s",var.workforce_pool_display_name)}" # this restricts the value to 34 characters or fewer 
  description       = "${var.workforce_pool_description}"
  disabled          = false
  session_duration  = "${var.workforce_pool_session_duration}"

  access_restrictions {
    allowed_services {
      domain = "backstory.chronicle.security"
    }
    disable_programmatic_signin = false
  }
}

#note this is valid when using workspace as an IDP
resource "google_iam_workforce_pool_provider" "workspace" {
  workforce_pool_id   = google_iam_workforce_pool.chronicle_pool.workforce_pool_id
  location            = google_iam_workforce_pool.chronicle_pool.location
  provider_id         = "provider-${var.project}"
  attribute_mapping   = {
    # GOOGLE_WORKSPACE
    "google.subject"       = "assertion.subject",
    "google.groups"        = "assertion.attributes.groups",
    "attribute.first_name" = "assertion.attributes.first_name[0]",
    "attribute.last_name"  = "assertion.attributes.last_name[0]",
    "attribute.user_email" = "assertion.attributes.user_email[0]",
    "google.display_name"  = "assertion.attributes.name[0]"
    # KEYCLOAK
    # "google.subject"       = "assertion.subject",
    # "google.groups"        = "assertion.attributes.groups",
    # "attribute.first_name" = "assertion.attributes.first_name[0]",
    # "attribute.last_name"  = "assertion.attributes.last_name[0]",
    # "attribute.user_email" = "assertion.attributes.user_email[0]",
    # "google.display_name"  = "assertion.attributes.display_name[0]"
  }
  saml {
    idp_metadata_xml  = "${var.saml_metadata}"
    }
  display_name        = "${format("%.34s",var.workforce_pool_provider_display_name)}" #${format("%.14s", var.project_name)}-redis
  description         = "${var.workforce_pool_provider_description}"
  disabled            = false
  attribute_condition = "true"
}

resource "google_project_iam_member" "secops_admin" {
 project = var.project
 role    = "roles/chronicle.admin"
 member  = "principalSet://iam.googleapis.com/${google_iam_workforce_pool.chronicle_pool.id}/group/${var.admin_group}"
}

resource "google_project_iam_member" "secops_editor" {
 project = var.project
 role    = "roles/chronicle.editor"
 member  = "principalSet://iam.googleapis.com/${google_iam_workforce_pool.chronicle_pool.id}/group/${var.editor_group}"
}

resource "google_project_iam_member" "secops_viewer" {
 project  = var.project
 role    = "roles/chronicle.viewer"
 member  = "principalSet://iam.googleapis.com/${google_iam_workforce_pool.chronicle_pool.id}/*"
}
