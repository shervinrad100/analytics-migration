# Service Account for Dashboard Workloads in GKE
resource "google_service_account" "dashboard_sa" {
  account_id   = "${var.environment}-dashboard-sa"
  display_name = "Service Account for Dashboard Workloads"
  project      = var.project_id
  description  = "Used by dashboard pods running in GKE with Workload Identity"
}

# Service Account for Data Scientists
resource "google_service_account" "data_scientist_sa" {
  account_id   = "${var.environment}-data-scientist-sa"
  display_name = "Service Account for Data Scientists"
  project      = var.project_id
  description  = "Used by data scientists for development and deployment"
}

# Grant dashboard service account access to Cloud Storage bucket
resource "google_storage_bucket_iam_member" "dashboard_sa_bucket_reader" {
  bucket = var.data_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.dashboard_sa.email}"
}

# Grant data scientists full access to Cloud Storage bucket
resource "google_storage_bucket_iam_member" "data_scientist_sa_bucket_admin" {
  bucket = var.data_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.data_scientist_sa.email}"
}

# Grant data scientists access to GKE for deployments
resource "google_project_iam_member" "data_scientist_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.data_scientist_sa.email}"
}

# Grant data scientists ability to view logs
resource "google_project_iam_member" "data_scientist_log_viewer" {
  project = var.project_id
  role    = "roles/logging.viewer"
  member  = "serviceAccount:${google_service_account.data_scientist_sa.email}"
}

# Grant dashboard users (government users) view-only access
resource "google_project_iam_member" "dashboard_users_viewer" {
  for_each = toset(var.dashboard_users_emails)
  project  = var.project_id
  role     = "roles/iap.httpsResourceAccessor"
  member   = "user:${each.value}"
}

# Grant data scientists access to their service account
resource "google_service_account_iam_member" "data_scientists_sa_user" {
  for_each           = toset(var.data_scientists_emails)
  service_account_id = google_service_account.data_scientist_sa.name
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${each.value}"
}

# Grant data scientists ability to impersonate their service account
resource "google_service_account_iam_member" "data_scientists_sa_token_creator" {
  for_each           = toset(var.data_scientists_emails)
  service_account_id = google_service_account.data_scientist_sa.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${each.value}"
}

# Workload Identity binding for dashboard pods
# This allows Kubernetes service accounts to act as GCP service accounts
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.dashboard_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[default/dashboard-sa]"
}

# Grant dashboard service account access to logs for debugging
resource "google_project_iam_member" "dashboard_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.dashboard_sa.email}"
}

# Grant dashboard service account access to monitoring for metrics
resource "google_project_iam_member" "dashboard_sa_monitoring_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.dashboard_sa.email}"
}
