import socket
import time
import os
import json
import boto3
import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from botocore.exceptions import ClientError
from decimal import Decimal , ROUND_HALF_UP

# Initialize CloudWatch Logs and CloudWatch clients
logs_client = boto3.client('logs')
cloudwatch_client = boto3.client('cloudwatch')
table_name = os.environ['DYNAMODB_TABLE']
region_name = os.environ['env_region']
lambda_log_group_name = os.environ['log_group_name']
dynamodb = boto3.resource('dynamodb', region_name=region_name)  # Specify your region
table = dynamodb.Table (table_name)  # Replace with your table name

# Define your CloudWatch Log Group and Log Stream
LOG_GROUP = lambda_log_group_name
LOG_STREAM = 'lambda-monitoring-log'

# Create the log group and stream if they don't exist
def create_log_group_and_stream():
    try:
        logs_client.create_log_group(logGroupName=LOG_GROUP)
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceAlreadyExistsException':
            raise

    try:
        logs_client.create_log_stream(logGroupName=LOG_GROUP, logStreamName=LOG_STREAM)
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceAlreadyExistsException':
            raise

create_log_group_and_stream()

def log_to_cloudwatch(message):
    timestamp = int(time.time() * 1000)  # Current time in milliseconds
    log_event = {
        'timestamp': timestamp,
        'message': message
    }
    
    try:
        # Put log events
        logs_client.put_log_events(
            logGroupName=LOG_GROUP,
            logStreamName=LOG_STREAM,
            logEvents=[log_event]
        )
    except ClientError as e:
        print(f"Failed to log to CloudWatch: {e}")

def log_metrics_to_cloudwatch(host, average_latency, packet_loss):
    try:
        # Put custom metrics
        cloudwatch_client.put_metric_data(
            Namespace='TCPMonitoring',
            MetricData=[
                {
                    'MetricName': 'AverageLatency',
                    'Dimensions': [
                        {
                            'Name': 'Host',
                            'Value': host
                        },
                    ],
                    'Value': average_latency,
                    'Unit': 'Milliseconds'
                },
                {
                    'MetricName': 'PacketLoss',
                    'Dimensions': [
                        {
                            'Name': 'Host',
                            'Value': host
                        },
                    ],
                    'Value': packet_loss,
                    'Unit': 'Percent'
                },
            ]
        )
    except ClientError as e:
        print(f"Failed to log metrics to CloudWatch: {e}")

def check_tcp_latency(host, port, timeout=2):
    start_time = time.time()
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(timeout)
            sock.connect((host, port))
            latency = (time.time() - start_time) * 1000  # Convert to milliseconds
            return host, latency, True  # Connection successful
    except (socket.timeout, socket.error):
        return host, None, False  # Connection failed

def monitor_server(hosts, port, attempts=10):
    results = {}

    for _ in range(attempts):
        with ThreadPoolExecutor(max_workers=len(hosts)) as executor:
            futures = {executor.submit(check_tcp_latency, host, port): host for host in hosts}

            for future in as_completed(futures):
                host = futures[future]
                latency, success = future.result()[1:]  # Unpack the result correctly

                if success:
                    if host not in results:
                        results[host] = {'latencies': [], 'success_count': 0}
                    results[host]['latencies'].append(latency)  # Append latency
                    results[host]['success_count'] += 1  # Increment success count
                else:
                    log_message = f"Connection to {host} failed (packet loss)"
                    print(log_message)
                    log_to_cloudwatch(log_message)
                    if host not in results:
                        results[host] = {'latencies': [], 'success_count': 0}
                    results[host]['success_count'] += 0  # No successful connections
            time.sleep(1)  # Optional: wait a second before the next round of attempts

    return results

def publish_metrics_to_dynamodb(host, average_latency, packet_loss):
    # Round the values to 2 decimal places using Decimal
    rounded_average_latency = Decimal(average_latency).quantize(Decimal('0.00'), rounding=ROUND_HALF_UP)
    rounded_packet_loss = Decimal(packet_loss).quantize(Decimal('0.00'), rounding=ROUND_HALF_UP)
    current_timestamp = int(time.time())
    # Convert to human-readable format
    human_readable_time = datetime.datetime.utcfromtimestamp(current_timestamp).strftime('%Y-%m-%d %H:%M:%S')
    try:
        response = table.put_item(
            Item={
                'lambda_aws_monitor': host,  # Include the required primary key
                'AverageLatency': rounded_average_latency,  # Already a Decimal
                'PacketLoss': rounded_packet_loss,  # Already a Decimal
                'Timestamp': current_timestamp,  # Unix timestamp
                'HumanReadableTimestamp': human_readable_time  # Human-readable timestamp
            }
        )
        print(f"Metrics published for {host}: {response}")
    except ClientError as e:
        print(f"Failed to publish metrics to DynamoDB: {e}")

def lambda_handler(event, context):
    server_hosts = event.get("hosts", ["10.200.4.10", "10.198.4.55", "10.202.4.10","10.196.4.10"])  # Default servers
    server_port = event.get("port", 53)  # Default port

    results = monitor_server(server_hosts, server_port)

    # Prepare the response
    response = []
    for host, data in results.items():
        average_latency = sum(data['latencies']) / data['success_count'] if data['success_count'] > 0 else 0
        packet_loss = (10 - data['success_count']) / 10 * 100  # Assuming 10 attempts
        response.append({
            "host": host,
            "average_latency": f"{average_latency} ms",
            "packet_loss": f"{packet_loss:.2f} %"
        })
        log_metrics_to_cloudwatch(host, average_latency, packet_loss)
        publish_metrics_to_dynamodb(host, average_latency, packet_loss)  # Publish to DynamoDB

    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }