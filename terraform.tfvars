# project  = "cellular-dream-342220"
project  = "gcp-terraform-env"
image    = "gcr.io/gcp-terraform-env/app"
region   = "us-east4"
location = "us-east4"
zone     = "us-east4-a"
name     = "Terraform Project"
gcp_service_list = [
  "iam.googleapis.com",
  "containerregistry.googleapis.com"
]
