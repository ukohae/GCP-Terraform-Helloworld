resource "google_storage_bucket" "auto-expire" {
  name          = "cloudquicklabs_gcp_bucket_iac-${random_id.unique.hex}"
  location      = "US"
  force_destroy = true

  public_access_prevention = "enforced"
}

resource "random_id" "unique" {
  byte_length = 4
}

resource "google_compute_instance" "default" {
  name         = "jenkins-vm-${random_id.unique.hex}"
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

# allow https
resource "google_compute_firewall" "allow-https" {
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