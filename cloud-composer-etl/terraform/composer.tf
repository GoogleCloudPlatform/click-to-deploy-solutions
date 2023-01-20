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

module "composer" {
  source  = "terraform-google-modules/composer/google//modules/create_environment_v2"
  version = "3.2.0"

  project_id               = var.project_id
  region                   = var.region
  composer_env_name        = var.composer_env_name
  composer_service_account = google_service_account.service_account.email
  image_version            = "composer-2.0.30-airflow-2.3.3"
  environment_size         = "ENVIRONMENT_SIZE_SMALL"
  labels                   = var.resource_labels

  network                          = module.vpc.network_name
  subnetwork                       = var.composer_env_name
  master_ipv4_cidr                 = var.composer_ip_ranges.master
  service_ip_allocation_range_name = "services"
  pod_ip_allocation_range_name     = "pods"
  use_private_environment          = true
  enable_private_endpoint          = true

  airflow_config_overrides ={
      secrets-backend = "airflow.providers.google.cloud.secrets.secret_manager.CloudSecretManagerBackend"
  }

  env_variables = {
    GCS_DATA_LAKE_BUCKET      = google_storage_bucket.data_lake.name
    GCS_SQL_BACKUP_BUCKET     = google_storage_bucket.sql_backup.name
    SQL_INSTANCE_NAME         = google_sql_database_instance.instance.name
  }

  pypi_packages = {
    # add additional packages here 
  }

  depends_on = [
    module.vpc,
    google_project_iam_member.composer_v2_extension
  ]
}
