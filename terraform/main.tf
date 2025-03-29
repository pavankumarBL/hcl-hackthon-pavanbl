resource "aws_lambda_function" "patient_service_lambda" {
  function_name = "patient-service-lambda"

  package_type = "Image"
  # image_uri    = aws_ecr_repository.patient_service_ecr.repository_url 
  image_uri = "539935451710.dkr.ecr.us-east-1.amazonaws.com/patient-service-repo:latest" 

  role = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  memory_size = 128
  timeout     = 10
}

resource "aws_lambda_function" "appointment_service_lambda" {
  function_name = "appointment-service-lambda"

  package_type = "Image"
  # image_uri    = aws_ecr_repository.appointment_service_ecr.repository_url  
  image_uri = "539935451710.dkr.ecr.us-east-1.amazonaws.com/appointment-service-repo:latest"

  role = aws_iam_role.lambda_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  memory_size = 128
  timeout     = 10
}
