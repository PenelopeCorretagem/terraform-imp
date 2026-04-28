variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "app_user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "rabbitmq_user" {
  description = "RabbitMQ user"
  type        = string
  default     = "penelopec-rebbitmq"
}

variable "rabbitmq_password" {
  description = "RabbitMQ password"
  type        = string
  sensitive   = true
}

variable "email" {
  description = "Email for notifications"
  type        = string
  sensitive   = true
}

variable "email_password" {
  description = "Email app password"
  type        = string
  sensitive   = true
}

variable "calcom_api_key" {
  description = "Cal.com API key"
  type        = string
  sensitive   = true
}

variable "calcom_webhook_secret" {
  description = "Cal.com webhook secret"
  type        = string
  sensitive   = true
}

variable "cloudinary_cloud_name" {
  description = "Cloudinary cloud name"
  type        = string
  sensitive   = true
}

variable "cloudinary_api_key" {
  description = "Cloudinary API key"
  type        = string
  sensitive   = true
}

variable "cloudinary_api_secret" {
  description = "Cloudinary API secret"
  type        = string
  sensitive   = true
}
