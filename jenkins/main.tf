resource "random_id" "unique" {
  byte_length = 4
}

resource "google_compute_instance" "default" {
  name         = "jenkins-vm-${random_id.unique.hex}"
  project      = var.project_id
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

  # metadata_startup_script = file("${path.module}/jenkins.sh")
}


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
