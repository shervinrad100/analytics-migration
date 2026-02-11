output "project_id" {
  description = "The GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "The GCP region"
  value       = var.region
}

output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "The endpoint for the GKE cluster"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "The cluster CA certificate"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "data_bucket_name" {
  description = "The name of the data storage bucket"
  value       = module.storage.bucket_name
}

output "data_bucket_url" {
  description = "The URL of the data storage bucket"
  value       = module.storage.bucket_url
}

output "oauth_client_id_secret" {
  description = "Secret Manager secret name for OAuth client ID"
  value       = var.enable_cloud_sql ? module.secrets[0].oauth_client_id_secret : null
}

output "oauth_client_secret_secret" {
  description = "Secret Manager secret name for OAuth client secret"
  value       = var.enable_cloud_sql ? module.secrets[0].oauth_client_secret_secret : null
}

output "dashboard_api_key_secret" {
  description = "Secret Manager secret name for dashboard API key"
  value       = var.enable_cloud_sql ? module.secrets[0].dashboard_api_key_secret : null
}

output "dashboard_service_account" {
  description = "Service account email for dashboard workloads"
  value       = module.iam.dashboard_service_account_email
}

output "data_scientist_service_account" {
  description = "Service account email for data scientists"
  value       = module.iam.data_scientist_service_account_email
}

output "kubectl_connection_command" {
  description = "Command to configure kubectl to connect to the GKE cluster"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}
