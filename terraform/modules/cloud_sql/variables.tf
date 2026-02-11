variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "dashboard_service_account_email" {
  type        = string
  description = "Service account email for dashboard workloads to access secrets"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to secrets"
  default     = {}
}
