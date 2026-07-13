resource "aws_sqs_queue" "job_queue" {
  name = "job-processing-queue"

  visibility_timeout_seconds = 60

  message_retention_seconds = 86400

  tags = {
    Name = "job-processing-queue"
  }
}
