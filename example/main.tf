module "terraform-aws-delay-s3-object-replication" {
  source                     = "./../modules/terraform-aws-delay-s3-object-replication"
  environment                = var.environment
  error_email_footer         = var.error_email_footer
  error_email_header         = var.error_email_header
  error_email_subject        = var.error_email_subject
  ms_teams_reporting_enabled = var.ms_teams_reporting_enabled
  ms_teams_webhook_url       = var.ms_teams_webhook_url
  region                     = var.region
  success_email_footer       = var.success_email_footer
  success_email_header       = var.success_email_header
  success_email_subject      = var.success_email_subject
  naming_prefix              = var.naming_prefix
  notification_emails        = var.notification_emails
  source_bucket              = var.source_bucket
  destination_bucket         = var.destination_bucket
  replication_delay_seconds  = var.replication_delay_seconds
}
