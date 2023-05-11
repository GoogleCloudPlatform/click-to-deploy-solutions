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

resource "google_compute_instance" "cloudsql_proxy" {
  name         = "cloudsql-proxy-${local.sql_instance_name}"
  machine_type = "e2-small"
  zone         = data.google_compute_zones.available.names[0]

  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-101-lts"
      labels = {
        vm_name = "cloudsql-proxy"
      }
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata_startup_script = <<EOF
  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  sudo bash add-google-cloud-ops-agent-repo.sh --also-install

  docker run -d -p 0.0.0.0:3306:3306 gcr.io/cloudsql-docker/gce-proxy:latest /cloud_sql_proxy -instances=${google_sql_database_instance.instance.connection_name}=tcp:0.0.0.0:3306
  EOF

  service_account {
    email  = google_service_account.sql_proxy_sa.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}

resource "google_compute_instance" "mysql_client" {
  name         = "mysql-client"
  machine_type = "e2-small"
  zone         = data.google_compute_zones.available.names[0]

  tags = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = google_compute_subnetwork.subnet.self_link
  }

  metadata_startup_script = <<EOF
  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  sudo bash add-google-cloud-ops-agent-repo.sh --also-install

  sudo apt update
  sudo apt upgrade -y
  sudo apt install mysql-client -y

  git clone https://github.com/datacharmer/test_db.git
  cd test_db

  MYSQL_IP=${google_compute_instance.cloudsql_proxy.network_interface.0.network_ip}
  mysql -h$MYSQL_IP -udatafusion -p${random_password.db_password.result} < employees.sql
  EOF

  service_account {
    email  = google_service_account.sql_proxy_sa.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
}
