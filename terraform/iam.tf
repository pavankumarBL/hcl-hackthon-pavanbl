resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-pavan"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# resource "aws_iam_policy" "lambda_policy" {
#   name        = "lambda-policy"
#   description = "Policy to allow Lambda functions to access resources"
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = ["logs:*", "s3:*", "dynamodb:*", "sns:*"]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Policy for Lambda to pull images from ECR and interact with CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetImage"
        ]
        Resource = [
          "arn:aws:ecr:us-east-1:539935451710:repository/patient-service-repo",
          "arn:aws:ecr:us-east-1:539935451710:repository/appointment-service-repo"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_apigateway_invocation" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}




resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}

resource "aws_iam_policy" "lambda_invoke_policy" {
  name        = "LambdaInvokePolicy"
  description = "Policy to allow API Gateway to invoke Lambda functions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "arn:aws:lambda:us-east-1:539935451710:function:appointment-service-lambda"
      }
    ]
  })
}
resource "aws_iam_role" "api_gateway_role" {
  name               = "APIGatewayInvokeLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.lambda_invoke_policy.arn
}


resource "aws_api_gateway_method_settings" "method_settings" {
  rest_api_id = aws_api_gateway_rest_api.api.id       # Replace with your actual API Gateway ID
  stage_name  = "prod"     # Replace with your actual stage name

  # Specify the method for which you're applying settings (e.g., GET)
  method_path = "GET"                 # Replace with your actual HTTP method

  # Define at least one setting inside the settings block
  settings {
    logging_level = "INFO"
    metrics_enabled = true
    data_trace_enabled = true  # Optionally enable data tracing
    throttling_burst_limit = 5000  # Example: Set burst limit for throttling
    throttling_rate_limit = 1000   # Example: Set rate limit for throttling
  }
}


