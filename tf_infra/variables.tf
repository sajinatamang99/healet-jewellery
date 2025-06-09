variable "aws_region" {
  type    = string
  default = "eu-west-2"
}
variable "ami_id" {
  type        = string
  default     = "ami-0a94c8e4ca2674d5a"
  description = "AMI for the instance"
}

variable "keypair" {
  type = string
  default = "healet-keypair"
  description = "key pair for healet-linux instance"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type"
}

variable "vpc_name" {
  type    = string
  default = "demo_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  default = {
    "private_subnet_1" = 0
    "private_subnet_2" = 1
  }
}

variable "public_subnets" {
  default = {
    "public_subnet_1" = 0
    "public_subnet_2" = 1
  }
}

# Variables for module:rds_mysql
variable "db_name" {
  default     = "healetdb"
  type = string
  description = "Database name"
}

variable "db_username" {
  default = "Your-Username"
  description = "Master DB username"
  type        = string
}
variable "db_password" {
  default = "Your-pwd"
  description = "Database password"
  type        = string
  sensitive   = true
}
variable "vpc_id" {
  description = "VPC ID to deploy RDS in"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "Security group(s) for RDS"
  type        = list(string)
}