resource "google_billing_budget" "budget" {
  provider = google-beta
# If var.enable_automatic_iam is not equal to 0 then create 1 resource, else create 0
  count    = var.project_monthly_budget != 0 ? 1 : 0

  billing_account = var.billing_account_id
  display_name    = format("%s Billing Budget", var.project_name)

  amount {
    specified_amount {
      currency_code = "USD"
      units = tostring(var.project_monthly_budget)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis = "FORECASTED_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis = "FORECASTED_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis = "FORECASTED_SPEND"
  }

}
