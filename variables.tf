variable "project_name" {
  type        = string
  description = "The name of the project to create.  No special characters please."
}

variable "project_owner" {
  type        = string
  description = "This must be a GCP IAM group.  This value will be assigned the role of \\\"Owner\\\" for the new project"
}

variable "project_monthly_budget" {
  type        = string
  description = "The estimated monthly spend for the project.  This value is used to setup budget alerting.  Only accepts integers."
}

variable "enable_automatic_iam" {
  type        = bool
  description = "Whether to auto-assign the project_owner group the Project Owner role. Defaults to false. If this is false, you must give the project_owner group the Project Owner role. If this is set to true, you cannot create additional google_project_iam resource objects."
  default     = "false"
}

variable "terraform_service_account" {
  type        = string
  description = "Email address of your terraform service account user. Needs to have permissions to link billing accounts and create resources at the organization/folder level."
}

variable "billing_account_id" {
  type        = string
  description = "Billing Account ID"
}

variable "organization_id" {
  type        = string
  description = "Billing Account ID"
}
