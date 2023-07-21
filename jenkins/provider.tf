terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}

provider "google" {
  credentials = file("../creds/serviceaccount.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}