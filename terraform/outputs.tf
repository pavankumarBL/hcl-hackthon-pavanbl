# Output the ECR repository URI to use in your GitHub Action
output "patient_service_ecr_uri" {
  value = aws_ecr_repository.patient_service_ecr.repository_url
}

output "appointment_service_ecr_uri" {
  value = aws_ecr_repository.appointment_service_ecr.repository_url
}