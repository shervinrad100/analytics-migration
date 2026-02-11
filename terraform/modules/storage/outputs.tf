output "bucket_name" {
  description = "The name of the Cloud Storage bucket"
  value       = google_storage_bucket.dashboard_data.name
}

output "bucket_url" {
  description = "The URL of the Cloud Storage bucket"
  value       = google_storage_bucket.dashboard_data.url
}

output "bucket_self_link" {
  description = "The self-link of the Cloud Storage bucket"
  value       = google_storage_bucket.dashboard_data.self_link
}
