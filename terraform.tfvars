# project  = "cellular-dream-342220"
project  = "terraform-project-100"
image    = "gcr.io/terraform-project-100/app"
region   = "us-east4"
location = "us-east4"
zone     = "us-east4-a"
name     = "Terraform Project"
gcp_service_list = [
  "iam.googleapis.com",
  "containerregistry.googleapis.com"
]
