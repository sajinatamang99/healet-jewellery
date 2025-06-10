variable "ami_id" {
  default     = "ami-0a94c8e4ca2674d5a"
  description = "AMI ID for Ubuntu"
  type        = string
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type"
  type        = string
}

variable "monitoring_keypair" {
  default     = "prometheus-keypair"
  description = "Key pair name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the resources should be created"
  type        = string
}

variable "monitoring_sg_ids" {
  type = list(string)
}
variable "monitoring_subnet_ids" {
  description = "List of subnet IDs to deploy monitoring instances (Prometheus/Grafana)"
  type        = list(string)
}
