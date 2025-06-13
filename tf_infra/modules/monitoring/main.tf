# Create an EC2 instance for prometheus monitoring server with the below specifications
resource "aws_instance" "monitoring" {
  key_name                    = var.monitoring_keypair
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.monitoring_sg_ids
  subnet_id                   = var.monitoring_subnet_ids
  associate_public_ip_address = true
  user_data                   = file("${path.module}/install-monitoring.sh")
  tags = {
    Name = "Prometheus-Monitoring-Server"
  }
}