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

# resource "google_project_service" "gcp_services" {
#   count                      = length(var.gcp_service_list)
#   project                    = var.project
#   service                    = var.gcp_service_list[count.index]
#   disable_dependent_services = true
# }

# resource "null_resource" "run_script" {
#   provisioner "local-exec" {
#     command = "/bin/sh docker-build.sh"
#   }
#   depends_on = [
#  google_project_service.gcp_services
#   ]
# }

# # Enables the Cloud Run API
# resource "google_project_service" "run_api" {
#   service = "run.googleapis.com"

#   disable_on_destroy = true
#   depends_on         = [null_resource.run_script]
# }

# resource "google_cloud_run_service" "webapp" {
#   name     = var.project
#   location = var.location

#   template {
#     spec {
#       containers {
#         image = var.image
#       }
#     }
#   }
#   traffic {
#     percent         = 100
#     latest_revision = true
#   }
#   # Waits for the Cloud Run API to be enabled
#   depends_on = [google_project_service.run_api]
# }

# # Allow unauthenticated users to invoke the service
# resource "google_cloud_run_service_iam_member" "run_all_users" {
#   service  = google_cloud_run_service.webapp.name
#   location = google_cloud_run_service.webapp.location
#   role     = "roles/run.invoker"
#   member   = "allUsers"
#   project  = google_cloud_run_service.webapp.project
# }

# resource "google_monitoring_alert_policy" "alert_policy" {
#   display_name = "Terraform Alert New Policy"
#   combiner     = "OR"
#   conditions {
#     display_name = "test new condition"
#     condition_threshold {
#       filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
#       duration   = "60s"
#       comparison = "COMPARISON_GT"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_RATE"
#       }
#     }
#   }

#   user_labels = {
#     foo = "bar"
#   }
# }


# resource "google_monitoring_uptime_check_config" "https" {
#   display_name = "Terraform New Uptime Check"
#   timeout      = "60s"

#   http_check {
#     path         = "/gcp-terraform-env/app"
#     port         = "443"
#     use_ssl      = true
#     validate_ssl = true
#   }

#   monitored_resource {
#     type = "uptime_url"
#     labels = {
#       project_id = var.project
#       host       = "gcr.io"
#     }
#   }

#   content_matchers {
#     content = "example"
#   }
# }

# resource "google_monitoring_dashboard" "dashboard" {
#   dashboard_json = <<EOF
# {
#   "displayName": "Demo Dashboard",
#   "gridLayout": {
#     "widgets": [
#       {
#         "blank": {}
#       }
#     ]
#   }
# }

# EOF
# }

# output "url" {
#   value = google_cloud_run_service.webapp.status[0].url
# }
