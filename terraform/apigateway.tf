# Create the API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "patient-appointment-api"
  description = "API for Patient and Appointment Services"
}

# Create /health resource (change from /patients to /health)
resource "aws_api_gateway_resource" "health_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "health"
}

# Create /appointments resource
resource "aws_api_gateway_resource" "appointment_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "appointments"
}

# Create GET method for /health (patients)
resource "aws_api_gateway_method" "health_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.health_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create GET method for /appointments
resource "aws_api_gateway_method" "appointment_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.appointment_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with Lambda for /health (patients)
resource "aws_api_gateway_integration" "health_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.health_resource.id
  http_method             = aws_api_gateway_method.health_method.http_method
  integration_http_method = "ANY"  # Corrected to "ANY" for AWS_PROXY
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.patient_service_lambda.invoke_arn
}

# Integration with Lambda for /appointments
resource "aws_api_gateway_integration" "appointment_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.appointment_resource.id
  http_method             = aws_api_gateway_method.appointment_method.http_method
  integration_http_method = "ANY"  # Corrected to "ANY" for AWS_PROXY
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.appointment_service_lambda.invoke_arn
}

# Deploy API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_method.health_method,
    aws_api_gateway_method.appointment_method,
    aws_api_gateway_integration.health_integration,
    aws_api_gateway_integration.appointment_integration
  ]
}

# Optional: Set up a stage for your API Gateway (prod stage)
resource "aws_api_gateway_stage" "prod_stage" {
  stage_name   = "prod"
  rest_api_id  = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}
