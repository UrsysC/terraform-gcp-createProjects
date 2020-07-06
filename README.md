# GCP Projects Module
This is a terraform module that helps you create and organize GCP projects in your environment. The goal of the module is to create projects that have billing budget alerts, clear project ownership, and a standard naming convention.

# Usage
Call this module to have a new project created in your organization and linked to your billing account.

## Prerequisites

1. You must have a terraform service account in your GCP environment with `roles/Owner` at the Organization level. This service account will be used to create your GCP project and link it to your billing account.  
2. You must run this as a user who is a member of a group that has `Service Account Token Creator`
   and `Service Account User` roles for your terraform service account.
3. If running locally, you need to run `gcloud auth application-default login` from you machine
   after you have the granted permissions from (2).  

## Inputs
| Variable Name  | Description  | Type  | Default Value  | Required  |
|---------------|--------------|-------|----------------|-----------|
| __*project_name*__  | Name and Project ID of the new project.  It has strict requirements.  Specifically, as of June 2020, the value must be 4 to 30 characters with lowercase and uppercase letters, numbers, hyphen, single-quote, double-quote, space, and exclamation point.  | string | N/A | Yes |
| __*project_owner*__  | This __MUST__ be a GCP IAM group. If enable_automatic_iam is set to true, this group will be automatically assigned the owner role in the newly created project. If you don't provide a group your `terraform plan` will pass but `terraform apply` with return a 400  | string. | N/A | Yes |
| __*project_monthly_budget*__  | The estimated monthly spend project spend.  | string | N/A | Yes |
| __*enable_automatic_iam*__  | Whether to auto-assign the project_owner group the Project Owner role. Defaults to true. If this is false, you must give the project_owner group the Project Owner role. If this is set to true, you cannot create additional google_project_iam resource objects.  | bool | true | Yes |
| __*terraform_service_account*__  | Email address of your terraform service account user. Needs to have permissions to link billing accounts and create resources at the organization/folder level. | string | N/A | Yes |
| __*billing_account_id*__  | Your Billing Account ID. | string | N/A | Yes |
| __*organization_id*__  | Your Organization ID. | string | N/A | Yes |

## Outputs
The module outputs the entire newly created project as an object named `created_project`.  Since the entire project is returned as an output you can use any attributes you wish from the origin codebase that called the module.

## Example - Create new project
The code below is all that's need to create a new project called "my-test-project".  The new project will be created in the your gcp organization and automatically linked to your billing account.
```terraform
terraform {
    required_version = ">=0.12.0"
}

module "gcp-create-project" {
  source  = "UrsysC/createProject/gcp/"
  version = "1.0"
  billing_account_id = "00000-00000-00000"
  organization_id = "000000000000"
  project_name = "my-test-project"
  project_owner = "gcp-admins@example.com"
  project_monthly_budget = 10
  enable_automatic_iam = true
  terraform_service_account = "terraform-createproject@[projectid].iam.gserviceaccount.com"
}
```
