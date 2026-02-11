variable "project_id" {
  type        = string
  description = "The GCP project ID for the analytics platform"
}

variable "project_name" {
  type        = string
  description = "Display name for the GCP project"
  default     = "Analytics Platform"
}

variable "region" {
  type        = string
  description = "Primary GCP region for resources (UK regions: europe-west2 for London, europe-west1 for Belgium)"
  default     = "europe-west2"
}

variable "organisation_id" {
  type        = string
  description = "GCP organization ID"
  default     = null
}

variable "folder_id" {
  type        = string
  description = "GCP folder ID for the project"
  default     = null
}

variable "billing_account_id" {
  type        = string
  description = "GCP billing account ID"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "prod"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
  default     = "analytics-dashboards"
}

variable "data_scientists_email_list" {
  type        = list(string)
  description = "List of data scientist email addresses for IAM access (e.g., ['alice@company.com', 'bob@company.com'])"
  default     = []
}

variable "dashboard_users_email_list" {
  type        = list(string)
  description = "List of dashboard user email addresses for read-only IAM access"
  default     = []
}

variable "enable_binary_authorization" {
  type        = bool
  description = "Enable Binary Authorization to ensure only signed/approved container images can run in GKE"
  default     = true
}

variable "enable_cloud_sql" {
  type        = bool
  description = "Enable Cloud SQL for dashboard metadata, configuration, and audit logs"
  default     = true
}

variable "cloud_sql_tier" {
  type        = string
  description = "Cloud SQL instance tier"
  default     = "db-f1-micro"
}

variable "data_storage_bucket_name" {
  type        = string
  description = "Name for the Cloud Storage bucket storing dashboard data (leave empty for auto-generated name)"
  default     = ""
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to all resources"
  default = {
    application = "analytics-platform"
    managed_by  = "terraform"
  }
}
