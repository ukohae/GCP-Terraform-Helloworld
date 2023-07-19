variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list(any)
}

variable "project_id" {
  type = string
}

variable "name" {
  type = string
}