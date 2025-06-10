#This shows AWS as the cloud provider and sets the region to "eu-west-2" (London)
provider "aws" {
  region = var.aws_region # Change to your preferred AWS region
}

#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {} #This retrieves the current AWS region that Terraform is using

# Create an EC2 instance with the below specifications
resource "aws_instance" "webserver" {
  key_name               = var.keypair
  ami                    = var.ami_id        # Replace with your region-specific AMI ID
  instance_type          = var.instance_type # Replace with your instance-type
  depends_on             = [aws_security_group.demo_sg, aws_subnet.public_subnets]
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  subnet_id              = [aws_subnet.public_subnets["public_subnet_1"].id, aws_subnet.public_subnets["public_subnet_2"].id]

  user_data = <<-EOF
    #!/bin/bash
    apt update
    apt install -y apache2

    # Clone your app from GitHub
    cd /opt
    git clone https://github.com/sajinatamang99/healet-jewellery.git
   
    # Remove the apache index/default page
    rm -rf /var/www/html/*
    # Copy or symlink to Apache web root:
    cp -r /opt/healet-jewellery/app/* /var/www/html/
    chown -R www-data:www-data /var/www/html

    systemctl enable apache2
    systemctl restart apache2
    EOF

  tags = {
    Name        = "demo-instance" # This is the instance name in AWS
    Environment = "demo"          # Optional additional tags
  }
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  root_block_device {
    encrypted = true
  }
}
# Pass the rds_mysql module with the below specifications
module "rds_mysql" {
  source      = "./modules/rds_mysql"
  db_username = var.db_username
  db_password = var.db_password
  vpc_id      = aws_vpc.vpc.id
  db_subnet_ids = [aws_subnet.private_subnets["private_subnet_1"].id,
  aws_subnet.private_subnets["private_subnet_2"].id]
  vpc_security_group_ids = [aws_security_group.rds_sg.id, aws_security_group.demo_sg.id]
  demo_sg                = aws_security_group.demo_sg.id #Pass this ONLY if needed in ingress rules
}

# Security Groups for RDS database
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL from EC2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.demo_sg.id] # Only allow EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Pass the monitoring module with the below specifications
module "monitoring" {
  source = "./modules/monitoring"
  # Pass required variables
  monitoring_keypair    = var.monitoring_keypair
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  vpc_id                = aws_vpc.vpc.id # Assuming you have a VPC module
  monitoring_subnet_ids = [aws_subnet.private_subnets["private_subnet_1"].id, aws_subnet.private_subnets["private_subnet_2"].id]
  monitoring_sg_ids     = [aws_security_group.rds_sg.id, aws_security_group.demo_sg.id]
}

# Terraform Resource Block - Security Group to Allow Traffic
resource "aws_security_group" "monitoring_sg" {
  name        = "monitor-security-group"
  description = "Allow Prometheus and Grafana traffic"
  vpc_id      = aws_vpc.vpc.id
  # ingress deals inbound rules
  # Allow Prometheus (Port 9090)
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (change for security if needed)
    description = "Allow Prometheus from office"
  }
  # Allow Grafana (Port 3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (change for security if needed)
    description = "Allow Grafana from office"
  }
  #egress deals outbound rules
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic out"
  }
  tags = {
    Name = "monitoring_sg"
  }
}

#vpc flow logs
resource "aws_cloudwatch_log_group" "vpc_logs" {
  name              = "/aws/vpc/flow-logs"
  retention_in_days = 14
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name = "vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  name = "vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "${aws_cloudwatch_log_group.vpc_logs.arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_cloudwatch_log_group.vpc_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.vpc.id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role.arn
}

#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "demo_environment"
    Terraform   = "true"
  }
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Create route tables for public and private subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_private_rtb"
    Terraform = "true"
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_igw_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "demo_nat_gateway"
  }
}

# Terraform Resource Block - Security Group to Allow Traffic
resource "aws_security_group" "demo_sg" {
  name        = "web-security-group"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.vpc.id
  # ingress deals inbound rules
  # Allow HTTP (Port 80) 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (change for security if needed)
    description = "Allow HTTP from office"
  }

  # Allow HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all (change for security if needed)
    description = "Allow HTTPS from office"
  }

  # Allow SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all, but it's better to restrict to your IP
    description = "Allow SSH"
  }
  #egress deals outbound rules
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow traffic out"
  }

  tags = {
    Name = "demo_sg"
  }
}