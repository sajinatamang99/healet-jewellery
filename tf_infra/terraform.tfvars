# VPC ID where RDS and EC2 will be deployed
vpc_id = "vpc-xxxxxxxxxxxxxxxxx"

# Private Subnet IDs where RDS should reside
db_subnet_ids = [
  "subnet-xxxxxxxxxxxxxxxx1",
  "subnet-xxxxxxxxxxxxxxxx2"
]

# Security Group IDs to attach to RDS
vpc_security_group_ids = [
  "sg-xxxxxxxxxxxxxxxx1",
  "sg-xxxxxxxxxxxxxxxx2"
]

# Optional: Other required variables
db_username = "admin"
db_password = "your-secure-password"
