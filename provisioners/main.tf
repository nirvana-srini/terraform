resource "aws_vpc" "my-vpc-lab" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc-lab"
  }
}

resource "aws_subnet" "my-public-subnet-01" {
  vpc_id     = aws_vpc.my-vpc-lab.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "my-public-subnet-01"
  }
}

resource "aws_subnet" "my-public-subnet-02" {
  vpc_id     = aws_vpc.my-vpc-lab.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "my-public-subnet-02"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc-lab.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-public-route-table" {
  vpc_id = aws_vpc.my-vpc-lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "my-public-route-table"
  }
}

resource "aws_route_table_association" "my-public-subnet-01-association" {
  subnet_id      = aws_subnet.my-public-subnet-01.id
  route_table_id = aws_route_table.my-public-route-table.id
}

resource "aws_route_table_association" "my-public-subnet-02-association" {
  subnet_id      = aws_subnet.my-public-subnet-02.id
  route_table_id = aws_route_table.my-public-route-table.id
}

resource "aws_security_group" "my-security-group" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.my-vpc-lab.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my-key-pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  ami                         = "ami-0567589d25e06853e"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my-key-pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.my-public-subnet-01.id
  security_groups             = [aws_security_group.my-security-group.id]
  tags = {
    Name = "bastion-host"
  }

  provisioner "local-exec" {
    command = "echo 'EC2 created successfully!' >> ./hello.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "touch /home/ec2-user/hello.txt",
      "echo 'EC2 created successfully!' >> /home/ec2-user/hello.txt"
    ]
  }

  provisioner "file" {
    source      = "./hello.txt"
    destination = "/tmp/hello.txt"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
    timeout     = "2m"
  }

}

