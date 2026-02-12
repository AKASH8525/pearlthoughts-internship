variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}

variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "akash2627/strapi-devops:day4"
}
