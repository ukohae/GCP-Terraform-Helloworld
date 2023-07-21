provider "google" {
  credentials = file("./creds/serviceaccount.json")
  project     = "gcp-terraform-env" # REPLACE WITH YOUR PROJECT ID
  region      = var.region
  zone        = var.zone
}
