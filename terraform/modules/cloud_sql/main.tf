# Secret Manager for storing sensitive configuration
# This replaces the need for a database to store passwords and secrets

# Example: OAuth client credentials for IAP
resource "google_secret_manager_secret" "oauth_client_id" {
  secret_id = "${var.environment}-oauth-client-id"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      environment = var.environment
      purpose     = "authentication"
    }
  )
}

resource "google_secret_manager_secret" "oauth_client_secret" {
  secret_id = "${var.environment}-oauth-client-secret"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      environment = var.environment
      purpose     = "authentication"
    }
  )
}

# Example: API keys for dashboards
resource "google_secret_manager_secret" "dashboard_api_key" {
  secret_id = "${var.environment}-dashboard-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      environment = var.environment
      purpose     = "api-access"
    }
  )
}

# Example: Database connection strings (if using external DB)
resource "google_secret_manager_secret" "db_connection_string" {
  secret_id = "${var.environment}-db-connection"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(
    var.labels,
    {
      environment = var.environment
      purpose     = "database"
    }
  )
}

# Grant service accounts access to secrets
resource "google_secret_manager_secret_iam_member" "dashboard_sa_access" {
  for_each = toset([
    google_secret_manager_secret.oauth_client_id.secret_id,
    google_secret_manager_secret.oauth_client_secret.secret_id,
    google_secret_manager_secret.dashboard_api_key.secret_id,
    google_secret_manager_secret.db_connection_string.secret_id,
  ])

  project   = var.project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.dashboard_service_account_email}"
}
