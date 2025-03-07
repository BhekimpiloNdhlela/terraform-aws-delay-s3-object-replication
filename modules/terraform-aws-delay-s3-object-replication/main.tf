resource "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket
}

resource "aws_s3_bucket_notification" "delay_s3_object_replication_source_bucket_notification" {
  bucket = aws_s3_bucket.source_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.delay_s3_object_replication_copy_object.arn
    events              = ["s3:ObjectCreated:*"]

    # # Conditionally include the prefix filter if it's set
    # filter_prefix = var.filter_prefix != "" ? var.filter_prefix : null

    # # Conditionally include the suffix filter if it's set
    # filter_suffix = var.filter_suffix != "" ? var.filter_suffix : null
  }
}

resource "aws_iam_role" "delay_s3_object_replication_lambda_exec_role" {
  name = "${var.naming_prefix}-copy-object-lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy_attachment" "delay_s3_object_replication_lambda_basic_execution" {
  name       = "${var.naming_prefix}-copy-object-lambda-basic-execution"
  roles      = [aws_iam_role.delay_s3_object_replication_lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delay_s3_object_replication_copy_object.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source_bucket.arn
  depends_on    = [aws_lambda_function.delay_s3_object_replication_copy_object]
}

resource "aws_iam_policy_attachment" "delay_s3_object_replication_lambda_s3_access" {
  name       = "${var.naming_prefix}-copy-object-lambda-s3-access"
  roles      = [aws_iam_role.delay_s3_object_replication_lambda_exec_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_lambda_function" "delay_s3_object_replication_copy_object" {
  filename      = data.archive_file.delay_s3_object_replication.output_path
  function_name = "${var.naming_prefix}-copy-object-lambda"
  role          = aws_iam_role.delay_s3_object_replication_lambda_exec_role.arn

  handler     = "index.handler"
  runtime     = "python3.10"
  timeout     = 180
  memory_size = 256

  source_code_hash = data.archive_file.delay_s3_object_replication.output_base64sha256
  depends_on       = [aws_cloudwatch_log_group.delay_s3_object_replication_lambda_logs]
  # layers           = [aws_lambda_layer_version.delay_s3_object_replication.arn]

  environment {
    variables = {
      SOURCE_BUCKET              = aws_s3_bucket.source_bucket.bucket
      DESTINATION_BUCKET         = var.destination_bucket
      SNS_TOPIC_ARN              = aws_sns_topic.delay_s3_object_replication_sns_topic.arn
      MS_TEAMS_WEBHOOK           = var.ms_teams_webhook_url
      ms_teams_reporting_enabled = var.ms_teams_reporting_enabled
    }
  }
}

# CloudWatch log group for the Lambda function
resource "aws_cloudwatch_log_group" "delay_s3_object_replication_lambda_logs" {
  name              = "/aws/lambda/${var.naming_prefix}-logging"
  retention_in_days = 7

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role" "delay_s3_object_replication_step_functions_role" {
  name = "${var.naming_prefix}-step-function-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "states.amazonaws.com" }
      Effect    = "Allow"
    }]
  })
}

resource "aws_iam_policy_attachment" "delay_s3_object_replication_step_functions_lambda" {
  name       = "${var.naming_prefix}-step-function-policy-attachment"
  roles      = [aws_iam_role.delay_s3_object_replication_step_functions_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_sfn_state_machine" "delay_s3_object_replication_workflow" {
  name     = "${var.naming_prefix}-copy-object-workflow"
  role_arn = aws_iam_role.delay_s3_object_replication_step_functions_role.arn

  definition = jsonencode({
    "StartAt" : "Wait",
    "States" : {
      "Wait" : {
        "Type" : "Wait",
        "Seconds" : var.replication_delay_seconds,
        "Next" : "ReplicateObject"
      },
      "ReplicateObject" : {
        "Type" : "Task",
        "Resource" : "${aws_lambda_function.delay_s3_object_replication_copy_object.arn}",
        "Retry" : [{
          "ErrorEquals" : ["States.ALL"],
          "IntervalSeconds" : var.error_retry_interval_seconds,
          "MaxAttempts" : var.error_retry_max_attempts,
          "BackoffRate" : var.error_retry_backoff_rate
        }],
        "Catch" : [{
          "ErrorEquals" : ["States.ALL"],
          "Next" : "NotifyError"
        }],
        "End" : true
      },
      "NotifyError" : {
        "Type" : "Task",
        "Resource" : "arn:aws:states:::sns:publish",
        "Parameters" : {
          "TopicArn" : "${aws_sns_topic.delay_s3_object_replication_sns_topic.arn}",
          "Message" : "Replication failed for object."
        },
        "End" : true
      }
    }
  })
}

resource "aws_sns_topic" "delay_s3_object_replication_sns_topic" {
  name = "${var.naming_prefix}-s3-replication-error-notifications"
}

resource "aws_sns_topic_subscription" "delay_s3_object_replication_subscribers" {
  for_each               = toset(var.notification_emails)
  topic_arn              = aws_sns_topic.delay_s3_object_replication_sns_topic.arn
  protocol               = "email"
  endpoint_auto_confirms = true
  endpoint               = each.value
}
