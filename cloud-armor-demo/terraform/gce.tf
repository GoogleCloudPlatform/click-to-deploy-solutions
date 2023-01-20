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

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "~> 7.6"

  project_id           = var.project_id
  name_prefix          = local.application_name
  region               = var.region
  network              = module.vpc.network_name
  subnetwork           = "webapp-${var.region}"
  service_account      = local.service_account
  labels               = local.resource_labels
  source_image         = "cos-stable-97-16919-29-40"
  source_image_project = "cos-cloud"
  machine_type         = "e2-small"
  preemptible          = true

  startup_script = <<EOF
  docker run --rm -p 80:3000 bkimminich/juice-shop:v14.0.1
  EOF

  tags = [
    "allow-hc",
    "allow-ssh"
  ]

  depends_on = [
    module.vpc
  ]
}

module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "~> 7.6.0"

  project_id        = var.project_id
  region            = var.region
  target_size       = 2
  hostname          = local.application_name
  instance_template = module.instance_template.self_link

  named_ports = [
    {
      name = "http"
      port = 80
    }
  ]
}
