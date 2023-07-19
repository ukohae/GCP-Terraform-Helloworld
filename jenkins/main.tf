resource "google_compute_instance" "default" {
  name         = "jenkins-vm"
  project      = "gcp-terraform-env"
  machine_type = "e2-small"
  zone         = "us-east4-a"


  tags = ["http", "https", "jenkins"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = file("${path.module}/jenkins.sh")
}

# resource "null_resource" "enable_service_usage_api" {
#   provisioner "local-exec" {
#     command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com --project ${var.project_id}"
#   }

#   #   depends_on = [google_project.my_project]
# }

# Wait for the new configuration to propagate
# (might be redundant)
# resource "time_sleep" "wait_project_init" {
#   create_duration = "60s"

#   depends_on = [null_resource.enable_service_usage_api]
# }


resource "google_compute_firewall" "default" {
  project = var.project_id
  name    = "jenkins"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]

  source_tags = ["jenkins"]
}

resource "google_compute_firewall" "allow-http" {
  project = var.project_id
  name    = "http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

# allow https
resource "google_compute_firewall" "allow-https" {
  project = var.project_id
  name    = "https"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}