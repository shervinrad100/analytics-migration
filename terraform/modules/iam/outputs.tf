output "dashboard_service_account_email" {
  description = "Email of the dashboard service account"
  value       = google_service_account.dashboard_sa.email
}

output "dashboard_service_account_name" {
  description = "Name of the dashboard service account"
  value       = google_service_account.dashboard_sa.name
}

output "data_scientist_service_account_email" {
  description = "Email of the data scientist service account"
  value       = google_service_account.data_scientist_sa.email
}

output "data_scientist_service_account_name" {
  description = "Name of the data scientist service account"
  value       = google_service_account.data_scientist_sa.name
}
