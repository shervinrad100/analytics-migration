terraform {
  required_version = "~> 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.8.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Backend configuration - update with your state management solution
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state/analytics-platform"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region

  user_project_override = true
}

provider "random" {}
