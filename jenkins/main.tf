resource "google_compute_instance" "default" {
  name         = "jenkins-vm"
  project      = "gcp-terraform-env"
  machine_type = "e2-small"
  zone         = "us-east4-a"

  tags = ["foo", "bar"]

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

resource "null_resource" "enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com --project ${var.project_id}"
  }

  #   depends_on = [google_project.my_project]
}

# Wait for the new configuration to propagate
# (might be redundant)
resource "time_sleep" "wait_project_init" {
  create_duration = "60s"

  depends_on = [null_resource.enable_service_usage_api]
}


resource "google_compute_firewall" "default" {
  project = var.project_id
  name    = "jenkins-port"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins"]
}