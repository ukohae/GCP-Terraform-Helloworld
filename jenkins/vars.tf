variable "region" {
  type = string
}

variable "location" {
  type = string
}

variable "zone" {
  type = string
}

variable "project" {
  type        = string
  description = "Project ID"
}

variable "image" {
  type        = string
  description = "Docker image tag"
}

variable "name" {
  type        = string
  description = "Project name"
}

variable "gcp_service_list" {
  description = "List of GCP service to be enabled for a project."
  type        = list(any)
}

variable "enable_service" {
  type    = bool
  default = false
}