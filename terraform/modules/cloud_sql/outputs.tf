output "oauth_client_id_secret" {
  description = "Secret Manager secret name for OAuth client ID"
  value       = google_secret_manager_secret.oauth_client_id.secret_id
}

output "oauth_client_secret_secret" {
  description = "Secret Manager secret name for OAuth client secret"
  value       = google_secret_manager_secret.oauth_client_secret.secret_id
}

output "dashboard_api_key_secret" {
  description = "Secret Manager secret name for dashboard API key"
  value       = google_secret_manager_secret.dashboard_api_key.secret_id
}

output "db_connection_string_secret" {
  description = "Secret Manager secret name for database connection string"
  value       = google_secret_manager_secret.db_connection_string.secret_id
}
