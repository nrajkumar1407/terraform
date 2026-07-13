# AWS LocalStack DevOps Demo

A complete Infrastructure as Code (IaC) demonstration using **Terraform** and **LocalStack** to provision a small AWS-based application 
stack locally.
The project provisions AWS infrastructure with Terraform, deploys a Python API and worker application using Docker, 
and demonstrates an asynchronous messaging workflow using Amazon SQS.

# Repository Structure

```text

├── terraform/
│   ├── provider.tf
│   ├── network.tf
│   ├── security.tf
│   ├── ec2.tf
│   ├── api_gateway.tf
│   ├── messaging.tf
│   ├── dynamodb.tf
│   ├── storage.tf
│   ├── iam.tf
│   ├── logs.tf
│   ├── outputs.tf
│   └── variables.tf
│
├── app/
│   ├── api/
│   │   ├── app.py
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   │
│   └── worker/
│       ├── worker.py
│       ├── Dockerfile
│       └── requirements.txt
│
├── docker/
│   └── docker-compose.yml
│
└── README.md
```

# Architecture Diagram

                                Developer
                                    |
                                    |
                             curl / Postman
                                    |
                                    v
                          http://localhost:4566
                                    |
                          +----------------------+
                          |    LocalStack        |
                          | AWS Cloud Emulator   |
                          +----------+-----------+
                                     |
        -------------------------------------------------------------------
        |             |             |             |             |          |
        |             |             |             |             |          |
        v             v             v             v             v          v

     API Gateway     SQS        DynamoDB        S3       CloudWatch      VPC
          |            |             |            |           |            |
          |            |             |            |           |            |
          +------------+-------------+------------+-----------+------------+
                                       |
                              Docker Containers
                                       |
                       +---------------+----------------+
                       |                                |
                       |                                |
                Python API Service               Python Worker
                       |                                |
             POST /tasks                      Poll SQS Queue
             GET /health                      Process Task
                                               |
                                      +--------+--------+
                                      |                 |
                                      |                 |
                                 CloudWatch Logs   DynamoDB


# Infrastructure Components

Terraform provisions the following AWS resources inside LocalStack:

| Resource         | Purpose                      |
| ---------------- | ---------------------------- |
| VPC              | Network isolation            |
| Public Subnet    | EC2 deployment               |
| Private Subnet   | Future application workloads |
| Internet Gateway | Internet routing             |
| Route Table      | Public routing               |
| Security Group   | EC2 firewall rules           |
| EC2 Instance     | Docker host                  |
| API Gateway      | HTTP API endpoint            |
| Amazon SQS       | Message queue                |
| Amazon DynamoDB  | Task persistence             |
| Amazon S3        | Object storage               |
| CloudWatch Logs  | Application logging          |

# Application Workflow

Client

   |
POST /tasks
   |
   v
API Service
   |
SendMessage()
   |
   v
Amazon SQS
   |
ReceiveMessage()
   |
   v
Worker Service
   |
Process Task
   |
   +------------------------+
   |                        |
   |                        |
   v                        v
DynamoDB              CloudWatch Logs

# Infrastructure Decisions
## Terraform

Terraform is used as the Infrastructure as Code (IaC) tool because it provides:

* Declarative infrastructure
* Repeatable deployments
* Version-controlled infrastructure
* Easy migration to a real AWS account

## LocalStack

LocalStack emulates AWS services locally, allowing development and testing without incurring AWS costs.
Benefits include:

* No AWS account required
* Fast development cycle
* Offline development
* Safe experimentation

## Docker

Both the API service and worker service are containerized to ensure:

* Consistent development environment
* Easy deployment
* Service isolation

## Amazon SQS

SQS decouples the API from the worker process.
Advantages:

* Asynchronous processing
* Increased reliability
* Improved scalability
* Fault tolerance

## DynamoDB

DynamoDB stores processed task information because it offers:

* Simple schema
* Low operational overhead
* High scalability

## Amazon S3

S3 is provisioned as object storage for future file upload functionality.

# Setup Instructions
## Prerequisites

Install the following tools:

* LocalStack CLI
* Docker 
* Terraform
* Python 
* AWS CLI

## Clone Repository

git clone https://github.com/<username>/aws-localstack-demo.git

cd aws-localstack-demo

## Start LocalStack

cd docker
docker compose up -d

Verify LocalStack is running:

docker ps

## Deploy Infrastructure

cd terraform
terraform init
terraform plan
terraform apply

Terraform creates:

* VPC
* Subnets
* Security Groups
* EC2
* API Gateway
* SQS Queue
* DynamoDB Table
* S3 Bucket
* CloudWatch Log Group
---

## Build Application

API
cd app/api
docker build -t demo-api .

Worker
cd app/worker
docker build -t demo-worker .

---
## Run Containers

docker compose up -d

---

# Testing

## Health Endpoint

GET /health

Example:

curl http://localhost:8080/health

Response

{
  "status": "healthy"
}
```
---

## Create Task

POST /tasks

Example

curl -X POST \
http://localhost:8080/tasks \
-H "Content-Type: application/json" \
-d '{
    "task":"Generate Report"
}'

Expected response

{
    "message":"Task queued"
}

Worker output

Received Task

Processing...

Stored in DynamoDB

Logged to CloudWatch

---

# Design Trade-offs

## Why LocalStack?

Pros

* No AWS charges
* Fast local development
* Easy CI integration

Cons

* Some AWS features are not fully implemented
* Behavior may differ slightly from the real AWS environment

---

## Why EC2 Instead of ECS?

For this demonstration, EC2 provides a simpler deployment target for Docker containers.
In production, Amazon ECS or Amazon EKS would be preferred.

---

## Why SQS?

Advantages:

* Loose coupling
* Retry capability
* Independent scaling
* Increased reliability

Trade-off:

Asynchronous processing introduces eventual consistency, meaning tasks are not processed immediately after submission.

---

## Why DynamoDB?

Pros

* Serverless
* Highly scalable
* Simple key-value access

Trade-off

Limited support for complex relational queries compared to traditional SQL databases.

---

# Running the System Locally

1. Install and Start Docker.
2. Install and Start LocalStack using Docker Compose.
3. Deploy infrastructure with Terraform.
4. Build the API and worker Docker images.
5. Start the application containers.
6. Submit tasks using the REST API.
7. Observe task processing through LocalStack CloudWatch logs and DynamoDB.
---

# Scaling to Real AWS

The same Terraform code can be adapted to deploy directly to AWS with minimal changes.
Recommended production enhancements include:

* Replace EC2 with Amazon ECS (Fargate) or Amazon EKS.
* Deploy API Gateway with Lambda or ECS integrations.
* Enable Auto Scaling Groups for compute resources.
* Store container images in Amazon ECR.
* Use Amazon RDS or Aurora for relational workloads if required.
* Configure CloudWatch Alarms and AWS X-Ray for observability.
* Store secrets in AWS Secrets Manager.
* Enable IAM roles with least-privilege access.
* Add CI/CD pipelines using GitHub Actions or AWS CodePipeline.
* Deploy resources across multiple Availability Zones for high availability.
---

# Future Improvements

* JWT authentication
* S3 file upload endpoint
* Terraform modules
* Automated integration tests
* GitHub Actions CI/CD pipeline
* ECS/Fargate or Kubernetes deployment
* CloudWatch dashboards
* Prometheus and Grafana monitoring
---

# Technology Stack

* Terraform
* LocalStack
* Docker
* Python
* Flask (or FastAPI)
* Boto3
* Amazon API Gateway
* Amazon SQS
* Amazon DynamoDB
* Amazon S3
* Amazon CloudWatch
* Jenkins / GitHub
===================================
Bonus (Optional)
===================================
CI Pipeline example
----------------------------------
CI Pipeline Example (GitHub Actions)

Although this project is intended to run locally with LocalStack, a CI pipeline can automatically validate infrastructure and
application code on every pull request or push.
name: CI Pipeline

on:
  push:
    branches:
      - main
      - develop

  pull_request:

jobs:

  terraform:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform -chdir=terraform init

      - name: Terraform Format
        run: terraform -chdir=terraform fmt -check

      - name: Terraform Validate
        run: terraform -chdir=terraform validate

  application:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Build API
        run: docker build -t api ./app/api

      - name: Build Worker
        run: docker build -t worker ./app/worker

      - name: Run Unit Tests
        run: pytest

=======================================================
Rate Limiting Strategy
========================================================
Although LocalStack does not fully emulate production API Gateway throttling, the architecture can support request rate limiting.

** Local Development **
Basic validation inside the API service
Reject malformed requests
Return HTTP 429 (Too Many Requests) when application limits are exceeded

** Production AWS **
Rate limiting would be configured using API Gateway Usage Plans and Throttle Settings.

Example:

100 requests/second
Burst limit of 200 requests
API Keys for authenticated clients
AWS WAF for additional protection against abuse and DDoS attacks

This protects backend services from excessive traffic while ensuring fair resource usage across clients.
=======================================================
Multi-Environment Setup
=======================================================
Terraform is designed to support multiple deployment environments with separate state files and variable definitions.

Example project structure:

terraform/
├── environments/
│   ├── dev.tfvars
│   ├── test.tfvars
│   └── prod.tfvars
│
├── provider.tf
├── networking.tf
├── sqs.tf
├── dynamodb.tf
└── variables.tf

Example deployments:

terraform apply -var-file=environments/dev.tfvars

terraform apply -var-file=environments/test.tfvars

terraform apply -var-file=environments/prod.tfvars

=> Each environment can define different values for:

VPC CIDR blocks
Resource names
DynamoDB capacity
EC2 instance types
Number of application instances
Logging configuration

For production deployments, a remote backend (such as an S3 bucket with DynamoDB state locking)
should be used to securely manage Terraform state.
=============================================================
Terraform modules
=============================================================
To improve maintainability and reusability, the infrastructure can be organized into Terraform modules instead of defining all resources
in a single configuration. Each module encapsulates a specific AWS service (for example, networking, compute, or messaging)with clearly
defined inputs and outputs. This modular approach reduces code duplication, simplifies testing, and makes it easier to reuse the same
infrastructure across development,testing, and production environments.

Example Module Structure

terraform/
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── ec2/
│   ├── s3/
│   ├── sqs/
│   ├── dynamodb/
│   ├── apigateway/
│   └── security-group/
│
├── environments/
│   ├── dev/
│   ├── test/
│   └── prod/
│
├── main.tf
├── provider.tf
└── versions.tf

Benefits
---------
Reusable infrastructure components
Easier maintenance and testing
Clear separation of responsibilities
Consistent deployments across environments
Simplified onboarding for new team members

=============================================================
Auto scaling design explanation
=============================================================
The current implementation uses a single EC2 instance to host the Docker containers, which is sufficient for local development and
demonstration purposes. In a production AWS environment, the application should be deployed on Amazon ECS (Fargate) or
an Auto Scaling Group (ASG) to improve availability, scalability, and fault tolerance.
The API service and worker service can scale independently based on demand. API instances can scale according to CPU utilization or
request count, while worker instances can scale based on the number of messages waiting in the SQS queue. This approach ensures that
resources are allocated efficiently, allowing the system to handle traffic spikes without over-provisioning during periods of low demand.

                                        Internet
                                            │
                                            ▼
                                 Application Load Balancer
                                            │
                               ┌────────────┴────────────┐
                               │                         │
                               ▼                         ▼
                 +---------------------------+   +---------------------------+
                 |      Auto Scaling Group   |   |   ECS Service Auto Scaling|
                 |      API Service          |   |      (Alternative)         |
                 +-------------+-------------+   +-------------+-------------+
                               │
             ┌─────────────────┼─────────────────┐
             ▼                 ▼                 ▼
      API Container      API Container      API Container
            │                  │                  │
            └──────────────────┴──────────────────┘
                               │
                               ▼
                         Amazon SQS Queue
                               │
                CloudWatch Queue Depth Metric
                               │
                               ▼
                 +-------------------------------+
                 | Worker Auto Scaling Group     |
                 | (Scale based on SQS messages) |
                 +---------------+---------------+
                                 │
              ┌──────────────────┼──────────────────┐
              ▼                  ▼                  ▼
        Worker Container   Worker Container   Worker Container
              │                  │                  │
              └──────────────┬───┴──────────────────┘
                             │
          ┌──────────────────┴─────────────────┐
          ▼                                    ▼
    Amazon DynamoDB                     CloudWatch Logs

Production Improvements
-------------------------
Deploy across multiple Availability Zones for high availability.
Use Amazon ECS Fargate to eliminate EC2 management.
Enable Application Auto Scaling policies for API and worker services.
Configure CloudWatch alarms to trigger scaling events.
Store container images in Amazon ECR.
Use an Application Load Balancer to distribute incoming traffic across multiple API instances.
Implement Dead Letter Queues (DLQs) for failed message processing.
Store Terraform state remotely in an S3 bucket with DynamoDB state locking.
Integrate a CI/CD pipeline (e.g., GitHub Actions or AWS CodePipeline) for automated deployment.

These additions show how the local proof-of-concept can evolve into a production-ready, highly available architecture while keeping the
same core design principles.

=============================================================
Architecture Decisions
============================================================
This solution adopts a loosely coupled, event-driven architecture to separate request handling from background processing.
The API service is responsible only for validating incoming requests and publishing messages to Amazon SQS,
while a dedicated worker asynchronously consumes and processes those messages.
This design improves reliability by allowing requests to be accepted quickly without waiting for long-running operations to complete.
The use of SQS also enables independent scaling of the API and worker components based on workload.

Terraform was selected as the Infrastructure as Code tool because it provides declarative,
version-controlled infrastructure that can be reproduced consistently across environments.
LocalStack enables the entire AWS stack—including API Gateway, SQS, DynamoDB, S3, and
CloudWatch—to run locally without requiring an AWS account, making development and testing faster and more cost-effective.
By containerizing the API and worker services with Docker, the application maintains a consistent runtime environment and
can later be migrated to production services such as Amazon ECS or EKS with minimal architectural changes.
============================================================
## Conclusion

This project demonstrates a complete DevOps workflow by provisioning AWS infrastructure with Terraform, emulating cloud services locally using LocalStack, and deploying a simple event-driven application with Docker and Python. It showcases Infrastructure as Code (IaC), containerization, asynchronous messaging, and local cloud development in a reproducible environment.

While the implementation is intentionally lightweight for demonstration purposes, the architecture has been designed with production principles in mind. The same approach can be extended to a real AWS environment by introducing services such as Amazon ECS/Fargate, Auto Scaling, Application Load Balancer, CI/CD pipelines, remote Terraform state management, monitoring, and security best practices. The modular infrastructure and loosely coupled application design provide a solid foundation for scaling and further enhancements.
-------------
** Thank you for reviewing this project. Feedback and suggestions are always welcome.**
-------------
