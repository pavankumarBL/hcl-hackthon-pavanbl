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



resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}
