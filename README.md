# Analytics Platform Migration - Terraform Infrastructure

This repository contains the Terraform infrastructure code for migrating an analytics platform from a monolithic architecture to a modern, cloud-native solution on Google Cloud Platform.

## Architecture Overview

The solution provisions:

- **GKE Autopilot Cluster**: Fully managed Kubernetes for hosting containerized Plotly Dash dashboards
- **Cloud Storage**: Secure, versioned storage for dashboard data files
- **Secret Manager**: Secure storage for OAuth credentials, API keys, and other secrets (replaces database-stored passwords)
- **IAM Configuration**: Role-based access control for data scientists and dashboard users
- **Binary Authorization**: Ensures only approved container images run in production
- **Workload Identity**: Secure service-to-service authentication without service account keys

## Key Design Decisions

### GKE Autopilot
- Fully managed infrastructure - Google handles node provisioning, scaling, and security patches
- Built-in security best practices
- Cost-optimized resource allocation
- UK region deployment (europe-west2 - London)

### Secret Manager vs Cloud SQL
- Replaced Cloud SQL password storage with Secret Manager
- Eliminates database maintenance overhead
- IAM-based access control for secrets
- Version control and audit logging for sensitive data

### Security Features
- **Binary Authorization**: Only signed/approved container images can deploy
- **Workload Identity**: Pods authenticate as service accounts without keys
- **Private GKE nodes**: Cluster nodes have no public IP addresses
- **Uniform bucket-level access**: Simplified and secure Cloud Storage IAM

## Prerequisites

1. **Google Cloud SDK**: Install from https://cloud.google.com/sdk
2. **Terraform**: Version ~> 1.6 (install from https://www.terraform.io/)
3. **GCP Project**: Existing project or permissions to create one
4. **Billing Account**: Active GCP billing account

## Project Structure

```
terraform/
├── main.tf                 # Main infrastructure configuration
├── providers.tf            # Provider configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (create from example)
└── modules/
    ├── gke/                # GKE Autopilot cluster
    ├── storage/            # Cloud Storage buckets
    ├── iam/                # Service accounts and IAM policies
    └── cloud_sql/          # Secret Manager (naming kept for compatibility)
```

## Getting Started

### 1. Authentication

```bash
# Authenticate with GCP
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### 2. Configuration

```bash
# Copy the example tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vim terraform.tfvars
```

Required variables:
- `project_id`: Your GCP project ID
- `region`: GCP region (default: europe-west2 for UK/London)
- `data_scientists_email_list`: List of data scientist emails
- `dashboard_users_email_list`: List of dashboard user emails

### 3. Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Usage

### Connecting to GKE Cluster

After deployment, connect to your GKE cluster:

```bash
# Get cluster credentials
gcloud container clusters get-credentials analytics-dashboards \
  --region europe-west2 \
  --project YOUR_PROJECT_ID

# Verify connection
kubectl get nodes
```

### Uploading Data to Cloud Storage

Data scientists can upload data files:

```bash
# Authenticate as data scientist service account
gcloud auth activate-service-account --key-file=key.json

# Upload data
gsutil cp data.csv gs://YOUR_BUCKET_NAME/raw/
```

### Deploying a Dashboard

Example Kubernetes deployment for a Plotly Dash dashboard:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sales-dashboard
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sales-dashboard
  template:
    metadata:
      labels:
        app: sales-dashboard
    spec:
      serviceAccountName: dashboard-sa
      containers:
      - name: dashboard
        image: gcr.io/YOUR_PROJECT_ID/sales-dashboard:latest
        ports:
        - containerPort: 8050
        env:
        - name: DATA_BUCKET
          value: "gs://YOUR_BUCKET_NAME"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
```

### Accessing Secrets

Dashboards can access secrets using the Google Cloud SDK:

```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()
secret_name = "projects/YOUR_PROJECT_ID/secrets/prod-oauth-client-id/versions/latest"
response = client.access_secret_version(request={"name": secret_name})
secret_value = response.payload.data.decode("UTF-8")
```

## IAM Roles

### Data Scientists
- **Cloud Storage**: Full access to upload/manage data files
- **GKE**: Deploy and manage dashboards
- **Logging**: View application logs
- **Service Account**: Impersonate data scientist service account

### Dashboard Users (Government Users)
- **IAP**: Access dashboards via Identity-Aware Proxy
- Read-only access to published dashboards

### Dashboard Workloads
- **Cloud Storage**: Read-only access to data files
- **Secret Manager**: Read access to secrets
- **Logging/Monitoring**: Write application logs and metrics

## Migration Strategy

### Phase 1: Foundation (2-3 weeks)
1. Provision infrastructure with Terraform
2. Set up GKE cluster and namespaces
3. Configure IAM and authentication
4. Set up CI/CD pipeline with GitHub Actions

### Phase 2: Pilot Dashboard (2-3 weeks)
1. Containerize one dashboard
2. Deploy to GKE
3. Validate routing and authentication
4. Test data access and performance

### Phase 3: Full Migration (4-6 weeks)
1. Containerize remaining dashboards
2. Migrate data to Cloud Storage
3. Deploy all dashboards to GKE
4. Decommission monolith

### Phase 4: Optimization (2 weeks)
1. Implement horizontal pod autoscaling
2. Set up monitoring dashboards
3. Optimize resource requests/limits
4. Document operational procedures

## CI/CD Integration

Example GitHub Actions workflow for deploying dashboards:

```yaml
name: Deploy Dashboard
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Build and Push Image
        run: |
          gcloud builds submit --tag gcr.io/$PROJECT_ID/dashboard:$GITHUB_SHA

      - name: Deploy to GKE
        run: |
          gcloud container clusters get-credentials analytics-dashboards \
            --region europe-west2 --project $PROJECT_ID
          kubectl set image deployment/dashboard dashboard=gcr.io/$PROJECT_ID/dashboard:$GITHUB_SHA
```

## Monitoring and Operations

### Viewing Logs

```bash
# View cluster logs
gcloud logging read "resource.type=k8s_cluster" --limit 50

# View pod logs
kubectl logs -f deployment/sales-dashboard
```

### Monitoring Dashboard Access

Use Cloud Monitoring to track:
- Dashboard response times
- User access patterns
- Resource utilization
- Error rates

### Backup and Disaster Recovery

- **Data**: Cloud Storage versioning enabled (90-day retention)
- **Cluster**: GKE automated backups and multi-zonal deployment
- **Secrets**: Secret Manager maintains version history

## Cost Optimization

- GKE Autopilot provides automatic resource optimization
- Cloud Storage lifecycle policies archive old data
- Use committed use discounts for sustained workloads
- Monitor costs with Cloud Billing budgets and alerts

## Security Considerations

1. **Binary Authorization**: Only approved images can deploy
2. **Private GKE**: Nodes have no public IPs
3. **Workload Identity**: No service account keys in containers
4. **IAP**: OAuth-based authentication for dashboard access
5. **Audit Logging**: All API calls logged for compliance

## Troubleshooting

### Cannot connect to GKE cluster
```bash
# Check cluster status
gcloud container clusters describe analytics-dashboards --region europe-west2

# Update kubeconfig
gcloud container clusters get-credentials analytics-dashboards --region europe-west2
```

### Permission denied accessing Cloud Storage
```bash
# Check service account permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:*"
```

### Dashboard cannot access secrets
```bash
# Verify Workload Identity binding
kubectl describe serviceaccount dashboard-sa

# Check secret permissions
gcloud secrets describe prod-oauth-client-id --format=json
```

## Maintenance

### Updating Terraform

```bash
# Update providers
terraform init -upgrade

# Review changes
terraform plan

# Apply updates
terraform apply
```

### GKE Cluster Upgrades

GKE Autopilot handles upgrades automatically during maintenance windows (configured for 3 AM UK time).

## Support and Contributing

For issues or questions:
1. Check the troubleshooting section
2. Review GCP documentation
3. Open an issue in this repository
