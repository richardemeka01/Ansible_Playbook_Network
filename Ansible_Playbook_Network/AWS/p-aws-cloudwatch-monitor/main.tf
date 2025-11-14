module "lambda_aws_monitor" {
  source = "./modules/lambda"
  providers = {
    aws.main = aws.net104-gnts-np-use1
  }
  for_each           = var.region_specs["net104-gnts-np"]["us-east-1"]
  filename           = each.value.filename
  function_name      = each.value.function_name
  iam_role           = each.value.iam_role
  handler            = each.value.handler
  security_group_ids = each.value.security_group_ids
  subnet_ids         = each.value.subnet_ids
  output_path        = each.value.output_path
  source_dir         = each.value.source_dir
  dynamodb_table     = each.value.dynamodb_table
  log_group_name     = each.value.log_group_name
}

module "lambda_aws_monitor_us_east-2" {
  source = "./modules/lambda"
  providers = {
    aws.main = aws.net101-gnts-pr-us-east-2
  }
  for_each           = var.region_specs["net104-gnts-np"]["us-east-2"]
  filename           = each.value.filename
  function_name      = each.value.function_name
  iam_role           = each.value.iam_role
  handler            = each.value.handler
  security_group_ids = each.value.security_group_ids
  subnet_ids         = each.value.subnet_ids
  output_path        = each.value.output_path
  source_dir         = each.value.source_dir
  dynamodb_table     = each.value.dynamodb_table
  log_group_name     = each.value.log_group_name
}

module "lambda_aws_monitor_eu_central_1" {
  source = "./modules/lambda"
  providers = {
    aws.main = aws.net101-gnts-pr-eu-central-1
  }
  for_each           = var.region_specs["net104-gnts-np"]["eu-central-1"]
  filename           = each.value.filename
  function_name      = each.value.function_name
  iam_role           = each.value.iam_role
  handler            = each.value.handler
  security_group_ids = each.value.security_group_ids
  subnet_ids         = each.value.subnet_ids
  output_path        = each.value.output_path
  source_dir         = each.value.source_dir
  dynamodb_table     = each.value.dynamodb_table
  log_group_name     = each.value.log_group_name
}

module "lambda_aws_monitor_ap_southeast_1" {
  source = "./modules/lambda"
  providers = {
    aws.main = aws.net101-gnts-pr-ap-southeast-1
  }
  for_each           = var.region_specs["net104-gnts-np"]["ap-southeast-1"]
  filename           = each.value.filename
  function_name      = each.value.function_name
  iam_role           = each.value.iam_role
  handler            = each.value.handler
  security_group_ids = each.value.security_group_ids
  subnet_ids         = each.value.subnet_ids
  output_path        = each.value.output_path
  source_dir         = each.value.source_dir
  dynamodb_table     = each.value.dynamodb_table
  log_group_name     = each.value.log_group_name
}