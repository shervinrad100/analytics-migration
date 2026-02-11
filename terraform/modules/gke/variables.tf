variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region for the cluster"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "cluster_name" {
  type        = string
  description = "Name of the GKE cluster"
}

variable "enable_binary_authorization" {
  type        = bool
  description = "Enable Binary Authorization for container image security"
  default     = true
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the cluster"
  default     = {}
}
