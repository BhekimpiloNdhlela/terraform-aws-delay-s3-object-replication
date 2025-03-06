"""
AWS Lambda function to replicate S3 objects from a source bucket to a destination bucket.

Notifications are sent via SNS (email) and optionally Microsoft Teams upon success or failure.
"""

import boto3
import os
import requests
import json

# Initialize AWS clients
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

# Environment variables
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')
MS_TEAMS_WEBHOOK_URL = os.environ.get('MS_TEAMS_WEBHOOK_URL')
MS_TEAMS_ENABLED = os.environ.get('MS_TEAMS_ENABLED', 'false').lower() == 'true'
SOURCE_BUCKET = os.environ.get('SOURCE_BUCKET')
DESTINATION_BUCKET = os.environ.get('DESTINATION_BUCKET')

def copy_objects(source_bucket: str, destination_bucket: str, key: str) -> None:
    """
    Copies an object from the source S3 bucket to the destination S3 bucket.

    Args:
        source_bucket (str): The source S3 bucket name.
        destination_bucket (str): The destination S3 bucket name.
        key (str): The key (path) of the object in the bucket.

    Returns:
        None
    """
    copy_source = {'Bucket': source_bucket, 'Key': key}
    try:
        s3_client.copy_object(Bucket=destination_bucket, CopySource=copy_source, Key=key)
        print(f"[INFO]: Object '{key}' successfully copied from '{source_bucket}' to '{destination_bucket}'.")
    except Exception as e:
        print(f"[ERROR]: Failed to copy object '{key}': {e}")
        send_email_notification("S3 Replication Failed", f"Failed to replicate object '{key}': {e}")
        if MS_TEAMS_ENABLED:
            send_ms_teams_notification(f"Failed to replicate object '{key}': {e}")
        raise

def send_email_notification(subject: str, message: str) -> None:
    """
    Sends a notification via SNS.

    Args:
        subject (str): The subject of the email notification.
        message (str): The body of the email notification.

    Returns:
        None
    """
    try:
        sns_client.publish(TopicArn=SNS_TOPIC_ARN, Subject=subject, Message=message)
        print("[INFO]: SNS notification sent successfully.")
    except Exception as e:
        print(f"[ERROR]: Failed to send SNS notification: {e}")
        raise

def send_ms_teams_notification(message: str) -> None:
    """
    Sends a message to Microsoft Teams via a webhook.

    Args:
        message (str): The message to send to the Teams channel.

    Returns:
        None
    """
    print("[INFO]: Microsoft Teams reporting is enabled.")
    headers = {"Content-Type": "application/json"}
    payload = {"text": message}
    try:
        response = requests.post(MS_TEAMS_WEBHOOK_URL, headers=headers, data=json.dumps(payload))
        response.raise_for_status()
        print(f"[INFO]: Message sent to Teams successfully. Status Code: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"[ERROR]: Failed to send message to Teams: {e}")
        raise

def lambda_handler(event: dict, context) -> dict:
    """
    AWS Lambda handler function.

    Args:
        event (dict): The event data passed to the Lambda function.
        context: The runtime information of the Lambda function.

    Returns:
        dict: Status message.
    """
    try:
        print("[INFO]: Lambda function triggered.")
        source_bucket = event.get('source_bucket', SOURCE_BUCKET)
        destination_bucket = event.get('destination_bucket', DESTINATION_BUCKET)
        key = event['key']

        copy_objects(source_bucket, destination_bucket, key)

        success_message = f"Object '{key}' replicated successfully."
        send_email_notification("S3 Replication Success", success_message)
        if MS_TEAMS_ENABLED:
            send_ms_teams_notification(success_message)
        send_email_notification("S3 Replication Completed", "The replication process has completed successfully.")

        print("[INFO]: Lambda function execution completed.")
        return {'status': 'Object replicated successfully'}
    except KeyError as e:
        error_message = f"Missing required key in event: {e}"
        print(f"[ERROR]: {error_message}")
        send_email_notification("S3 Replication Failed", error_message)
        raise
    except Exception as e:
        error_message = f"Unexpected error: {e}"
        print(f"[ERROR]: {error_message}")
        send_email_notification("S3 Replication Failed", error_message)
        raise
