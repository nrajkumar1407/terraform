from fastapi import FastAPI
import boto3
import json
import uuid
import os


app = FastAPI()


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


@app.get("/health")
def health():
    return {
        "status": "ok"
    }


@app.post("/jobs")
def create_job():

    job_id = str(uuid.uuid4())

    message = {
        "jobId": job_id,
        "task": "process-file"
    }


    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(message)
    )


    return {
        "jobId": job_id,
        "status": "queued"
    }
