variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  default     = "penelope-secret-key-change-me-in-production"
  sensitive   = true
}
