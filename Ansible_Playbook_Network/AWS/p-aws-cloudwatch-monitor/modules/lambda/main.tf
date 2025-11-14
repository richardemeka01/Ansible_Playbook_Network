
data "aws_region" "current" {
  provider = aws.main
}

locals {
  filename = path.module
}

resource "aws_lambda_function" "lambda_function" {
  provider      = aws.main
  filename      = var.filename
  function_name = var.function_name
  role          = var.iam_role
  handler       = var.handler
  runtime       = "python3.8"
  timeout       = 60
  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [var.subnet_ids]
    security_group_ids = [var.security_group_ids]
  }
  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table
      env_region     = data.aws_region.current.name
      log_group_name = var.log_group_name
    }
  }
}


resource "aws_dynamodb_table" "dynamodb_table" {
  provider     = aws.main
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "lambda_aws_monitor"

  attribute {
    name = "lambda_aws_monitor" # Primary key attribute name
    type = "S"                  # S for String, N for Number, B for Binary
  }
}

data "archive_file" "zip_python_code" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = var.output_path
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  provider          = aws.main
  name              = var.log_group_name
  retention_in_days = 30
  depends_on        = [aws_lambda_function.lambda_function]
}

# Event scheduler

resource "aws_scheduler_schedule" "lambda_event_rule" {
  provider            = aws.main
  name                = "lambda_event_rule"
  group_name          = "default"
  schedule_expression = "rate(1 minute)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.lambda_function.arn
    role_arn = var.iam_role
  }
  depends_on = [aws_lambda_function.lambda_function]
}