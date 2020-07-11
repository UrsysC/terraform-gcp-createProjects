# for testing purposes
data "google_billing_account" "account" {
  provider = google-beta
  billing_account = var.billing_account_id
}

resource "google_billing_budget" "budget" {
  provider = google-beta
  billing_account = data.google_billing_account.account.id
  display_name = "Example Billing Budget"
  amount {
    specified_amount {
      currency_code = "USD"
      units = "100000"
    }
  }
  threshold_rules {
      threshold_percent =  0.5
      spend_basis = "FORECASTED_SPEND"
  }
}
