region_specs = {
    net104-gnts-np = {
        us-east-1 ={
            cloudwatch_latency_monitor = {
                filename = "./python/monitor.zip"
                function_name = "lambda-aws-internal-monitor"
                iam_role = "arn:aws:iam::676063845817:role/IPmonitoring-vpc-service-role"
                handler = "monitor.lambda_handler" #Name of the python file
                subnet_ids = "subnet-08b5bc3dfcfc2a6bd"
                security_group_ids = "sg-01f921dae62bb9a94"
                source_dir ="./python"
                output_path = "./python/monitor.zip"
                dynamodb_table = "lambda_aws_monitor"
                log_group_name = "/aws/lambda/lambda-aws-internal-monitor"
            }
        }
        us-east-2 ={
            cloudwatch_latency_monitor = {
                filename = "./python/monitor.zip"
                function_name = "lambda-aws-internal-monitor"
                iam_role = "arn:aws:iam::676063845817:role/IPmonitoring-vpc-service-role"
                handler = "monitor.lambda_handler" #Name of the python file
                subnet_ids = "subnet-092dafd239f3f87fc"
                security_group_ids = "sg-0400544097a13fee3"
                source_dir ="./python"
                output_path = "./python/monitor.zip"
                dynamodb_table = "lambda_aws_monitor"
                log_group_name = "/aws/lambda/lambda-aws-internal-monitor"
            }
        } 
        eu-central-1 ={
            cloudwatch_latency_monitor = {
                filename = "./python/monitor.zip"
                function_name = "lambda-aws-internal-monitor"
                iam_role = "arn:aws:iam::676063845817:role/IPmonitoring-vpc-service-role"
                handler = "monitor.lambda_handler" #Name of the python file
                subnet_ids = "subnet-091e4c48caf1b30c0"
                security_group_ids = "sg-0d1952a2693a31a2f"
                source_dir ="./python"
                output_path = "./python/monitor.zip"
                dynamodb_table = "lambda_aws_monitor"
                log_group_name = "/aws/lambda/lambda-aws-internal-monitor"
            }
        } 
        ap-southeast-1 ={
            cloudwatch_latency_monitor = {
                filename = "./python/monitor.zip"
                function_name = "lambda-aws-internal-monitor"
                iam_role = "arn:aws:iam::676063845817:role/IPmonitoring-vpc-service-role"
                handler = "monitor.lambda_handler" #Name of the python file
                subnet_ids = "subnet-05dac65c55b2dff4b"
                security_group_ids = "sg-0bb6dc2a6d2d50d25"
                source_dir ="./python"
                output_path = "./python/monitor.zip"
                dynamodb_table = "lambda_aws_monitor"
                log_group_name = "/aws/lambda/lambda-aws-internal-monitor"
            }
        }     
    }
}