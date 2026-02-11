# Create the GCP project (optional - if you need Terraform to create the project)
resource "google_project" "analytics_project" {
  count               = var.organisation_id != null || var.folder_id != null ? 1 : 0
  project_id          = var.project_id
  name                = var.project_name
  org_id              = var.organisation_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account_id
  auto_create_network = true

  labels = var.labels
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "iap.googleapis.com",
    "cloudkms.googleapis.com",
    "binaryauthorization.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
  ])

  service            = each.key
  disable_on_destroy = false

  depends_on = [google_project.analytics_project]
}

# Cloud Storage for dashboard data
module "storage" {
  source = "./modules/storage"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  bucket_name = var.data_storage_bucket_name != "" ? var.data_storage_bucket_name : "${var.project_id}-dashboard-data"
  labels      = var.labels

  depends_on = [google_project_service.required_apis]
}

# GKE Autopilot Cluster for running dashboards
module "gke" {
  source = "./modules/gke"

  project_id                  = var.project_id
  region                      = var.region
  environment                 = var.environment
  cluster_name                = var.gke_cluster_name
  enable_binary_authorization = var.enable_binary_authorization
  labels                      = var.labels

  depends_on = [google_project_service.required_apis]
}

# IAM and Security
module "iam" {
  source = "./modules/iam"

  project_id             = var.project_id
  gke_cluster_name       = module.gke.cluster_name
  data_scientists_emails = var.data_scientists_email_list
  dashboard_users_emails = var.dashboard_users_email_list
  data_bucket_name       = module.storage.bucket_name
  labels                 = var.labels

  depends_on = [
    google_project_service.required_apis,
    module.gke,
    module.storage
  ]
}

# Secret Manager for storing sensitive configuration (passwords, OAuth credentials, etc.)
module "secrets" {
  source = "./modules/cloud_sql"
  count  = var.enable_cloud_sql ? 1 : 0

  project_id                      = var.project_id
  environment                     = var.environment
  dashboard_service_account_email = module.iam.dashboard_service_account_email
  labels                          = var.labels

  depends_on = [
    google_project_service.required_apis,
    module.iam
  ]
}
