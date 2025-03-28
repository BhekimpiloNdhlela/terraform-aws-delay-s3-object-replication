provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "Environment"                 = var.environment
      "workload.owner"              = "n/a"
      "technical.environment"       = var.environment
      "technical.terraform.managed" = "true"
      "workload.project"            = "n/a"
      "Name"                        = "S3ObjectReplicationDelay"
      "Application"                 = "S3 Object Replication Delay"
      "Department"                  = "enhancement"
      "Purpose"                     = "enable S3 object replication delay"
      "Compliance"                  = "n/a"
      "Backup"                      = "false"
      "Lifecycle"                   = "active"
      "Criticality"                 = "high"
      "CreatedBy"                   = "terraform"
    }
  }
}