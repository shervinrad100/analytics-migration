output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.analytics_cluster.name
}

output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.analytics_cluster.id
}

output "cluster_endpoint" {
  description = "The endpoint for the GKE cluster API server"
  value       = google_container_cluster.analytics_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The cluster CA certificate for TLS verification"
  value       = google_container_cluster.analytics_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location (region) of the GKE cluster"
  value       = google_container_cluster.analytics_cluster.location
}

output "cluster_self_link" {
  description = "The self-link of the GKE cluster"
  value       = google_container_cluster.analytics_cluster.self_link
}
