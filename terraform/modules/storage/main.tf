# Cloud Storage bucket for dashboard data files
resource "google_storage_bucket" "dashboard_data" {
  name          = var.bucket_name
  location      = var.region
  project       = var.project_id
  storage_class = "STANDARD"

  # Prevent accidental deletion
  force_destroy = false

  # Enable versioning for data recovery
  versioning {
    enabled = true
  }

  # Lifecycle rules for cost optimization
  lifecycle_rule {
    condition {
      age = 90
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  # Uniform bucket-level access for simpler IAM
  uniform_bucket_level_access = true

  # Labels
  labels = merge(
    var.labels,
    {
      environment = var.environment
      purpose     = "dashboard-data"
    }
  )

  # Public access prevention
  public_access_prevention = "enforced"
}

# Optional: Create folders/prefixes using objects with trailing slashes
resource "google_storage_bucket_object" "data_folders" {
  for_each = toset([
    "raw/",
    "processed/",
    "dashboards/",
    "uploads/",
  ])

  name    = each.key
  content = " "
  bucket  = google_storage_bucket.dashboard_data.name
}
