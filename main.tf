resource "null_resource" "run_script" {
  provisioner "local-exec" {
    command = "/bin/bash docker-build.sh"
  }
}

# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
  depends_on         = [null_resource.run_script]
}

resource "google_cloud_run_service" "webapp" {
  name     = var.project
  location = var.location

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.webapp.name
  location = google_cloud_run_service.webapp.location
  role     = "roles/run.invoker"
  member   = "allUsers"
  project  = google_cloud_run_service.webapp.project
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "Terraform Alert Policy"
  combiner     = "OR"
  conditions {
    display_name = "test condition"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/disk/write_bytes_count\" AND resource.type=\"gce_instance\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  user_labels = {
    foo = "bar"
  }
}


resource "google_monitoring_uptime_check_config" "https" {
  display_name = "Terraform Uptime Check"
  timeout      = "60s"

  http_check {
    path         = "/cellular-dream-342220/app"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project
      host       = "gcr.io"
    }
  }

  content_matchers {
    content = "example"
  }
}

resource "google_monitoring_dashboard" "dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Terraform Dashboard",
  "gridLayout": {
    "columns": "2",
    "widgets": [
      {
        "title": "Widget 1",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "LINE"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      },
      {
        "text": {
          "content": "Widget 2",
          "format": "MARKDOWN"
        }
      },
      {
        "title": "Widget 3",
        "xyChart": {
          "dataSets": [{
            "timeSeriesQuery": {
              "timeSeriesFilter": {
                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
                "aggregation": {
                  "perSeriesAligner": "ALIGN_RATE"
                }
              },
              "unitOverride": "1"
            },
            "plotType": "STACKED_BAR"
          }],
          "timeshiftDuration": "0s",
          "yAxis": {
            "label": "y1Axis",
            "scale": "LINEAR"
          }
        }
      }
    ]
  }
}

EOF
}

output "url" {
  value = google_cloud_run_service.webapp.status[0].url
}
