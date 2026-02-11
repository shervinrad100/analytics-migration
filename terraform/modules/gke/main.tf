# GKE Autopilot Cluster
# Autopilot is fully managed - Google handles node provisioning, scaling, security, and upgrades
resource "google_container_cluster" "analytics_cluster" {
  provider = google-beta
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Enable Autopilot mode for fully managed infrastructure
  enable_autopilot = true

  # Autopilot clusters automatically enable Workload Identity
  # This allows pods to authenticate as service accounts without keys
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Network configuration (uses default network if not specified)
  network    = "default"
  subnetwork = "default"

  # IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""
  }

  # Binary Authorization enforcement
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Release channel for automatic upgrades
  release_channel {
    channel = "REGULAR"
  }

  # Maintenance window (UK timezone friendly)
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # Enable logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Security and networking features
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Resource labels
  resource_labels = merge(
    var.labels,
    {
      environment = var.environment
      cluster     = var.cluster_name
    }
  )

  # Deletion protection
  deletion_protection = true

  # Note: Autopilot automatically manages:
  # - Node pools and autoscaling
  # - Node OS and security patches
  # - Vertical Pod Autoscaling
  # - Node auto-repair and auto-upgrade
  # - Optimized resource allocation
}
