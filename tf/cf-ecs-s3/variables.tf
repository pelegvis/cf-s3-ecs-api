variable "domain_name" {
  type = string
  default = "cf-s3-ecs-demo-bucket"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "api_name" {
  type = string
  default = "demo-app"
}

variable "api_image" {
  type = string
}

variable "api_port" {
  type = number
  default = 5011
}

variable "lb_health_check_path" {
  type = string
  default = "/v1/health"
}