variable "environment" {
  type        = string
  description = "The environment in which resources are deployed (e.g., dev, test, prod)."

  validation {
    condition     = length(var.environment) > 0
    error_message = "The 'environment' variable must not be empty."
  }
}

variable "naming_prefix" {
  type        = string
  description = "The prefix used for naming AWS resources."

  validation {
    condition     = length(var.naming_prefix) > 0
    error_message = "The 'naming_prefix' variable must not be empty."
  }
}

variable "region" {
  type        = string
  description = "The AWS region to deploy resources."

  validation {
    condition     = length(var.region) > 0
    error_message = "The 'region' variable must not be empty."
  }
}

variable "notification_emails" {
  type        = list(string)
  description = "A list of email addresses to receive notifications."

  validation {
    condition     = length(var.notification_emails) > 0
    error_message = "The 'notification_emails' variable must contain at least one email address."
  }
}

variable "ms_teams_reporting_enabled" {
  type        = bool
  description = "Flag to enable or disable MS Teams reporting."

  validation {
    condition     = var.ms_teams_reporting_enabled == true || var.ms_teams_reporting_enabled == false
    error_message = "The 'ms_teams_reporting_enabled' variable must be either true or false."
  }
}

variable "ms_teams_webhook_url" {
  type        = string
  description = "The MS Teams webhook URL for reporting."

  validation {
    condition     = length(var.ms_teams_webhook_url) > 0
    error_message = "The 'ms_teams_webhook_url' variable must not be empty."
  }
}

variable "error_email_subject" {
  type        = string
  description = "The subject of error notification emails."

  validation {
    condition     = length(var.error_email_subject) > 0
    error_message = "The 'error_email_subject' variable must not be empty."
  }
}

variable "error_email_header" {
  type        = string
  description = "The header content of error notification emails."

  validation {
    condition     = length(var.error_email_header) > 0
    error_message = "The 'error_email_header' variable must not be empty."
  }
}

variable "error_email_footer" {
  type        = string
  description = "The footer content of error notification emails."

  validation {
    condition     = length(var.error_email_footer) > 0
    error_message = "The 'error_email_footer' variable must not be empty."
  }
}

variable "success_email_subject" {
  type        = string
  description = "The subject of success notification emails."

  validation {
    condition     = length(var.success_email_subject) > 0
    error_message = "The 'success_email_subject' variable must not be empty."
  }
}

variable "success_email_header" {
  type        = string
  description = "The header content of success notification emails."

  validation {
    condition     = length(var.success_email_header) > 0
    error_message = "The 'success_email_header' variable must not be empty."
  }
}

variable "success_email_footer" {
  type        = string
  description = "The footer content of success notification emails."

  validation {
    condition     = length(var.success_email_footer) > 0
    error_message = "The 'success_email_footer' variable must not be empty."
  }
}

variable "replication_delay_seconds" {
  type        = number
  description = "The number of seconds to delay object replication."

  validation {
    condition     = var.replication_delay_seconds > 0
    error_message = "The 'replicatioin_delay_seconds ' variable must be greater than 0."
  }
}

variable "destination_bucket" {
  type        = string
  description = "The name of the destination S3 bucket for object replication."

  validation {
    condition     = length(var.destination_bucket) > 0
    error_message = "The 'destination_bucket' variable must not be empty."
  }
}

variable "source_bucket" {
  type        = string
  description = "The name of the source S3 bucket for object replication."

  validation {
    condition     = length(var.source_bucket) > 0
    error_message = "The 'source_bucket' variable must not be empty."
  }
}

variable "error_retry_interval_seconds" {
  type        = number
  description = "The initial wait time in seconds before retrying a failed task."

  validation {
    condition     = var.error_retry_interval_seconds > 0
    error_message = "The 'error_retry_interval_seconds' variable must be greater than 0."
  }
}

variable "error_retry_max_attempts" {
  type        = number
  description = "The maximum number of retry attempts for a failed task."

  validation {
    condition     = var.error_retry_max_attempts > 0
    error_message = "The 'error_retry_max_attempts' variable must be greater than 0."
  }
}

variable "error_retry_backoff_rate" {
  type        = number
  description = "The exponential backoff rate for retries."

  validation {
    condition     = var.error_retry_backoff_rate > 0
    error_message = "The 'error_retry_backoff_rate' variable must be greater than 0."
  }
}

variable "s3_event_notification_filter_prefix" {
  type        = string
  description = "The prefix to filter objects in the source bucket for replication."
  default     = null

  validation {
    condition     = var.s3_event_notification_filter_prefix == null || can(regex(".*", var.s3_event_notification_filter_prefix))
    error_message = "The filter prefix must be either null or a non-empty string."
  }
}

variable "s3_event_notification_filter_suffix" {
  type        = string
  description = "The suffix to filter objects in the source bucket for replication."
  default     = null

  validation {
    condition     = var.s3_event_notification_filter_suffix == null || can(regex(".*", var.s3_event_notification_filter_suffix))
    error_message = "The filter suffix must be either null or a non-empty string."
  }
}
