variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region for the storage bucket"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "bucket_name" {
  type        = string
  description = "Name of the Cloud Storage bucket"
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to the bucket"
  default     = {}
}
