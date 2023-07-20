provider "google" {
  # Make sure to set the appropriate credentials here, or use the default application credentials on your system.
  credentials = file("${path.module}/gcp-terraform-env-a55f4d96d7df.json")
  project     = var.project_id
  region      = "us-east4" # Replace with your desired region
}

# resource "google_project" "my_project" {
#   name       = "My Terraform Project"
#   project_id = var.project_id

#   # Add the IAM binding for the service account with the required role.
#   iam_policy {
#     policy_data = data.google_iam_policy.policy_data.policy_data
#   }
# }

resource "google_project_iam_binding" "project" {
  project = var.project_id
  role    = "roles/resourcemanager.projectCreator"
  members = [
    "user:871427462978-compute@developer.gserviceaccount.com",
  ]
}

# Define the IAM policy data to include the required role.
data "google_iam_policy" "policy_data" {
  binding {
    role = "roles/resourcemanager.projectCreator"

    # Replace the following with the email of your service account.
    members = [
      "serviceAccount:871427462978-compute@developer.gserviceaccount.com"
    ]
  }
}

# Add the required OAuth 2.0 scopes to the service account.
# resource "google_service_account" "account" {
#   account_id   = "my-terraform-sa" # Replace with your desired service account ID
#   display_name = "My Terraform Service Account"

#   # Add the scopes required by your application.
#   scopes = [
#     "https://www.googleapis.com/auth/compute",
#     "https://www.googleapis.com/auth/cloud-platform",
#     "https://www.googleapis.com/auth/cloud-identity",
#     "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
#     "https://www.googleapis.com/auth/devstorage.full_control",
#     "https://www.googleapis.com/auth/userinfo.email"
#   ]
# }
