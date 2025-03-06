# Delay S3 Object Replication

This Terraform module sets up a solution for delaying S3 object replication using AWS Step Functions and Lambda functions. The module integrates with SNS for notifications and supports custom delays for replication processes.

## Project Structure

```
.
├── example
│   ├── README.md
│   ├── main.tf
│   ├── terraform.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── variables.tf
│   └── variables.tfvars
├── infra-documentation
│   └── track.git
├── modules
│   └── terraform-aws-delay-s3-object-replication
│       ├── builds
│       │   └── lambda
│       │       └── delay-s3-object-replication.zip
│       ├── lambda
│       │   └── delay-s3-object-replication
│       │       └── index.py
│       ├── data.tf
│       ├── main.tf
│       ├── variables.tf
│       └── versions.tf
├── LICENSE
└── README.md
```

## Variables

| Name                          | Type          | Description                                                          | Validation                                |
|------------------------------- |-------------- |----------------------------------------------------------------------|------------------------------------------ |
| `environment`                  | string        | The environment for resource deployment (e.g., dev, test, prod).       | Must not be empty.                        |
| `naming_prefix`                | string        | The prefix used for naming AWS resources.                             | Must not be empty.                        |
| `region`                       | string        | The AWS region to deploy resources.                                    | Must not be empty.                        |
| `notification_emails`          | list(string)  | List of email addresses for notifications.                             | Must contain at least one email address.  |
| `ms_teams_reporting_enabled`   | bool          | Flag to enable or disable MS Teams reporting.                          | Must be true or false.                    |
| `ms_teams_webhook_url`         | string        | The MS Teams webhook URL for reporting.                                | Must not be empty.                        |
| `error_email_subject`          | string        | Subject for error notification emails.                                 | Must not be empty.                        |
| `error_email_header`           | string        | Header content for error notification emails.                          | Must not be empty.                        |
| `error_email_footer`           | string        | Footer content for error notification emails.                          | Must not be empty.                        |
| `success_email_subject`        | string        | Subject for success notification emails.                               | Must not be empty.                        |
| `success_email_header`         | string        | Header content for success notification emails.                        | Must not be empty.                        |
| `success_email_footer`         | string        | Footer content for success notification emails.                        | Must not be empty.                        |
| `replication_delay_seconds`    | number        | The number of seconds to delay object replication.                     | Must be greater than 0.                   |
| `destination_bucket`           | string        | The name of the destination S3 bucket for replication.                  | Must not be empty.                        |
| `source_bucket`                | string        | The name of the source S3 bucket for replication.                      | Must not be empty.                        |

## Usage

Example usage in `example/main.tf`:

```hcl
module "delay_s3_object_replication" {
  source                      = "../modules/terraform-aws-delay-s3-object-replication"
  environment                 = var.environment
  naming_prefix               = var.naming_prefix
  region                      = var.region
  notification_emails         = var.notification_emails
  ms_teams_reporting_enabled  = var.ms_teams_reporting_enabled
  ms_teams_webhook_url        = var.ms_teams_webhook_url
  error_email_subject         = var.error_email_subject
  error_email_header          = var.error_email_header
  error_email_footer          = var.error_email_footer
  success_email_subject       = var.success_email_subject
  success_email_header        = var.success_email_header
  success_email_footer        = var.success_email_footer
  replication_delay_seconds   = var.replication_delay_seconds
  destination_bucket          = var.destination_bucket
  source_bucket               = var.source_bucket
}
```

## Deployment

1. Initialize Terraform:

```bash
terraform init
```

2. Validate the configuration:

```bash
terraform validate
```

3. Plan the deployment:

```bash
terraform plan
```

4. Apply the configuration:

```bash
terraform apply
```

## License

This project is licensed under the MIT License.

