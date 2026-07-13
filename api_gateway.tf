resource "aws_api_gateway_rest_api" "health_api" {
  name = "health-api"
}


resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id
  parent_id   = aws_api_gateway_rest_api.health_api.root_resource_id
  path_part   = "health"
}


resource "aws_api_gateway_method" "health_get" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id
  resource_id = aws_api_gateway_resource.health.id

  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_mock" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id
  resource_id = aws_api_gateway_resource.health.id

  http_method = "GET"

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}


resource "aws_api_gateway_method_response" "health_response" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id
  resource_id = aws_api_gateway_resource.health.id

  http_method = "GET"
  status_code = "200"
  depends_on = [
    aws_api_gateway_method.health_get
 ]
}

resource "aws_api_gateway_integration_response" "health_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id
  resource_id = aws_api_gateway_resource.health.id

  http_method = "GET"
  status_code = "200"

  response_templates = {
    "application/json" = "{\"status\":\"ok\"}"
  }

  depends_on = [
    aws_api_gateway_integration.health_mock
  ]
}

resource "aws_api_gateway_deployment" "health_deployment" {
  rest_api_id = aws_api_gateway_rest_api.health_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.health_get.id,
      aws_api_gateway_integration.health_mock.id,
      aws_api_gateway_integration_response.health_integration_response.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration_response.health_integration_response
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.health_api.id
  deployment_id = aws_api_gateway_deployment.health_deployment.id
  stage_name    = "dev"
}
