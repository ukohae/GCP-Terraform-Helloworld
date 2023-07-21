resource "google_compute_instance" "default" {
  count        = var.create_jenkins ? 1 : 0
  name         = "jenkins-vm"
  project      = var.project
  machine_type = "e2-medium"
  zone         = "us-east4-a"


  tags = ["http-server", "https-server", "jenkins"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
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

  metadata_startup_script = file("${path.module}/jenkins.sh")
}

resource "null_resource" "enable_service_usage_api" {
  count = var.enable_service ? 1 : 0
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com compute.googleapis.com --project ${var.project}"
  }
}

resource "time_sleep" "wait_project_init" {
  count           = var.enable_service ? 1 : 0
  create_duration = "60s"

  depends_on = [null_resource.enable_service_usage_api]
}


resource "google_compute_firewall" "default" {
  count   = var.enable_service ? 1 : 0
  project = var.project
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
  count   = var.enable_service ? 1 : 0
  project = var.project
  name    = "http"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http"]
}

resource "google_compute_firewall" "allow-https" {
  count   = var.enable_service ? 1 : 0
  project = var.project
  name    = "https"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https"]
}