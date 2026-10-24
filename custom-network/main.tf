resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom_igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "public_route_table"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "custom_sg" {
  name        = "custom_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "bastion_key_pair" {
  key_name   = "bastion-key-pair"
  public_key = file(pathexpand("~/.ssh/bastion-key.pub"))
}

resource "aws_instance" "bastion" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.custom_sg.id]
  associate_public_ip_address = true
  key_name = aws_key_pair.bastion_key_pair.key_name

  tags = {
    Name = "bastion"
  }
}

resource "aws_s3_bucket" "custom_bucket" {
  bucket = "custom-bucket-terraform-2026-06-24"
  tags = {
    Name = "custom_bucket"
  }
}

resource "aws_security_group" "custom_sg_rds" {
  name        = "custom_sg_rds"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.custom_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }
  tags = {
    Name = "custom_sg_rds"
  }
}


# create private subnet for RDS
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_subnet_1"
  }
}

# create second private subnet for RDS
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_db_subnet_group" "custom_db_subnet_group" {
  name       = "custom-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "custom_db_subnet_group"
  }
}

resource "aws_db_instance" "primary" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "users-db-instance"
  db_name              = "users_db" # initial database name
  username             = "admin"
  password             = "password123" #use aws secrets manager to store the password
  #storage_encrypted   = true
  publicly_accessible  = false
  multi_az             = false
  parameter_group_name = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.custom_sg_rds.id]
  db_subnet_group_name = aws_db_subnet_group.custom_db_subnet_group.name
  skip_final_snapshot  = true
  backup_retention_period = 7
  maintenance_window    = "Mon:00:00-Mon:03:00"
}

resource "aws_db_instance" "replica" {
  replicate_source_db  = aws_db_instance.primary.arn
  instance_class       = "db.t3.micro"
  identifier           = "users-db-replica"
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.custom_sg_rds.id]
  db_subnet_group_name = aws_db_subnet_group.custom_db_subnet_group.name
  skip_final_snapshot  = true
}