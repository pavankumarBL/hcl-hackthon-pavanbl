resource "aws_ecr_repository" "patient_service_ecr" {
  name = "patient-service-repo"
}

resource "aws_ecr_repository" "appointment_service_ecr" {
  name = "appointment-service-repo"
}
