variable "db_username" {}
variable "db_password" {}

variable "vpc_id" {
  description = "VPC ID for the RDS instance and SG"
  type        = string
}
variable "db_subnet_ids" {
  type = list(string)
}

variable "vpc_security_group_ids" {
  type = list(string)
}
variable "demo_sg" {
  type = string
}
