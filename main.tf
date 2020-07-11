terraform {
  required_version = ">=0.12.0"
}

# setup a provider that is tied to the user running terraform
provider "google" {
  version = "~> 3.11"
  alias   = "user"
}

# Use the credentials of the user that invokes this TF to go and create an
# access token for the service account we want to impersonate.
data "google_service_account_access_token" "create-project-service-user" {
  provider               = google.user
  target_service_account = var.terraform_service_account
  scopes                 = ["cloud-platform"]
  # Expire the access token after 5 minutes.  TF shouldn't take longer than that to run.
  lifetime = "300s"
}

# Setup a provider that is used when we want to be the impersonated service account
provider "google" {
  access_token = data.google_service_account_access_token.create-project-service-user.access_token
}

provider "google-beta" {
  # google-beta tf provider is required for google billing budget
  # we use the terarform service account to make these calls as well
  access_token = data.google_service_account_access_token.create-project-service-user.access_token
}

data "google_billing_account" "billing_account" {
  # Do this as our impersonated user for use by impersonated user later
  provider        = google-beta
  billing_account = var.billing_account_id
}

# Create GCP project
resource "google_project" "created_project" {
  # Do this as our impersonated user
  provider        = google
  name            = var.project_name
  project_id      = var.project_name
  org_id          = var.organization_id
  billing_account = data.google_billing_account.billing_account.id
  # No network by default b/c why would we want a network if we didn't explicitly ask for one.
  auto_create_network = false
  # If true, the Terraform resource can be deleted without deleting the Project via the Google API.
  # skip_delete = false
  labels = {
    managed-by-terraform    = "true"
    estimated-monthly-spend = var.project_monthly_budget
  }
}

# Create the iam policy for the project if var.enable_automatic_iam is true
data "google_iam_policy" "project_owners" {
  # Do this as our impersonated user
  provider = google
  # If var.enable_automatic_iam is true then create 1 resource, else create 0
  count = var.enable_automatic_iam ? 1 : 0
  binding {
    role = "roles/owner"

    members = [
      "group:${var.project_owner}",
    ]
  }
}

# Assign "project_owner" as owner if var.enable_automatic_iam is true
resource "google_project_iam_policy" "created_project_policy" {
  # Do this as our impersonated user
  provider = google
  # If var.enable_automatic_iam is true then create 1 resource, else create 0
  count       = var.enable_automatic_iam ? 1 : 0
  project     = google_project.created_project.id
  policy_data = data.google_iam_policy.project_owners[0].policy_data
}
