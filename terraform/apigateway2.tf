# Lambda IAM Role for API Gateway
resource "aws_iam_role" "lambda_api_gateway_role" {
  name = "lambda-api-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# Permissions for API Gateway to invoke Lambda
resource "aws_iam_policy" "lambda_invoke_api_gateway_policy" {
  name        = "lambda-invoke-api-gateway-policy"
  description = "Allow API Gateway to invoke Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = [
          aws_lambda_function.patient_service_lambda.arn,
          aws_lambda_function.appointment_service_lambda.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_api_gateway_policy_attachment" {
  name       = "lambda-api-gateway-policy-attachment"
  policy_arn = aws_iam_policy.lambda_invoke_api_gateway_policy.arn
  roles      = [aws_iam_role.lambda_api_gateway_role.name]
}

# Create the API Gateway
resource "aws_api_gateway_rest_api" "patient_appointment_api" {
  name        = "patient-appointment-api"
  description = "API for patient service and appointment service Lambda functions"
}

# Create resources for API Gateway
resource "aws_api_gateway_resource" "patient_resource" {
  rest_api_id = aws_api_gateway_rest_api.patient_appointment_api.id
  parent_id   = aws_api_gateway_rest_api.patient_appointment_api.root_resource_id
  path_part   = "patient"
}

resource "aws_api_gateway_resource" "appointment_resource" {
  rest_api_id = aws_api_gateway_rest_api.patient_appointment_api.id
  parent_id   = aws_api_gateway_rest_api.patient_appointment_api.root_resource_id
  path_part   = "appointment"
}

# Create the POST method for patient service Lambda
resource "aws_api_gateway_method" "patient_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.patient_appointment_api.id
  resource_id   = aws_api_gateway_resource.patient_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Create the POST method for appointment service Lambda
resource "aws_api_gateway_method" "appointment_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.patient_appointment_api.id
  resource_id   = aws_api_gateway_resource.appointment_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integration of POST method with patient service Lambda
resource "aws_api_gateway_integration" "patient_integration" {
  rest_api_id = aws_api_gateway_rest_api.patient_appointment_api.id
  resource_id = aws_api_gateway_resource.patient_resource.id
  http_method = aws_api_gateway_method.patient_post_method.http_method
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.patient_service_lambda.arn}/invocations"
}

# Integration of POST method with appointment service Lambda
resource "aws_api_gateway_integration" "appointment_integration" {
  rest_api_id = aws_api_gateway_rest_api.patient_appointment_api.id
  resource_id = aws_api_gateway_resource.appointment_resource.id
  http_method = aws_api_gateway_method.appointment_post_method.http_method
  type        = "AWS_PROXY"
  uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.appointment_service_lambda.arn}/invocations"
}

# Grant API Gateway permissions to invoke Lambda functions
resource "aws_lambda_permission" "allow_api_gateway_patient_lambda" {
  statement_id  = "AllowExecutionFromAPIGatewayPatient"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.patient_service_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "allow_api_gateway_appointment_lambda" {
  statement_id  = "AllowExecutionFromAPIGatewayAppointment"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.appointment_service_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.patient_appointment_api.id
}

# Output the API Gateway URL
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.patient_appointment_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/prod"
}
