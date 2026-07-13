import boto3
import json
import time
import os


sqs = boto3.client(
    "sqs",
    endpoint_url=os.getenv(
        "AWS_ENDPOINT_URL",
        "http://localhost:4566"
    ),
    region_name="us-east-1"
)


QUEUE_URL = os.getenv(
    "QUEUE_URL",
    "http://localhost:4566/000000000000/job-processing-queue"
)


print("Worker started...")
print("Queue:", QUEUE_URL)

while True:

    response = sqs.receive_message(
        QueueUrl=QUEUE_URL,
        MaxNumberOfMessages=1,
        WaitTimeSeconds=10
    )


    messages = response.get("Messages", [])


    for msg in messages:

        body = json.loads(msg["Body"])

        print(
            "Processing job:",
            body
        )


        # Later:
        # upload to S3
        # update DynamoDB


        sqs.delete_message(
            QueueUrl=QUEUE_URL,
            ReceiptHandle=msg["ReceiptHandle"]
        )


    time.sleep(2)
