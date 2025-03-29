# resource "aws_api_gateway_rest_api" "api" {
#   name        = "patient-appointment-api"
#   description = "API for Patient and Appointment Services"
# }

# resource "aws_api_gateway_resource" "patient_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "patients"
# }

# resource "aws_api_gateway_resource" "appointment_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   parent_id   = aws_api_gateway_rest_api.api.root_resource_id
#   path_part   = "appointments"
# }

# resource "aws_api_gateway_method" "patient_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.patient_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_method" "appointment_method" {
#   rest_api_id   = aws_api_gateway_rest_api.api.id
#   resource_id   = aws_api_gateway_resource.appointment_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "patient_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.patient_resource.id
#   http_method = aws_api_gateway_method.patient_method.http_method
#   integration_http_method = "POST"
#   type                     = "AWS_PROXY"
#   uri                      = aws_lambda_function.patient_service_lambda.invoke_arn
# }

# resource "aws_api_gateway_integration" "appointment_integration" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
#   resource_id = aws_api_gateway_resource.appointment_resource.id
#   http_method = aws_api_gateway_method.appointment_method.http_method
#   integration_http_method = "POST"
#   type                     = "AWS_PROXY"
#   uri                      = aws_lambda_function.appointment_service_lambda.invoke_arn
# }

# resource "aws_api_gateway_deployment" "api_deployment" {
#   rest_api_id = aws_api_gateway_rest_api.api.id
# }
