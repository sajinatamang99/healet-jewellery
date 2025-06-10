resource "aws_db_subnet_group" "mysql_subnet_group" {
  name       = "mysql-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name = "MySQL DB subnet group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier              = "healet-mysql-db"
  allocated_storage       = 20
  storage_encrypted       = true
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.mysql_subnet_group.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7
  multi_az                = false

  tags = {
    Name = "healet-mysql"
  }
}
