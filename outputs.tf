output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "instance_id" {
  value = aws_instance.docker_host.id
}

output "health_endpoint" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.health_api.id}/dev/_user_request_/health"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.file_storage.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.application_data.name
}

output "sqs_queue_url" {
  value = aws_sqs_queue.job_queue.url
}

