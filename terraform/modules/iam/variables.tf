variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "prod"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "data_scientists_emails" {
  type        = list(string)
  description = "List of data scientist email addresses"
  default     = []
}

variable "dashboard_users_emails" {
  type        = list(string)
  description = "List of dashboard user email addresses"
  default     = []
}

variable "data_bucket_name" {
  type        = string
  description = "Name of the Cloud Storage bucket for data"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to resources"
  default     = {}
}
