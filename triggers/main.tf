resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "my-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "my-subnet"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-route-table" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
}

resource "aws_route_table_association" "my-route-table-association" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-route-table.id
}

resource "aws_security_group" "my-security-group" {
  vpc_id = aws_vpc.my-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
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
resource "aws_key_pair" "my-key-pair-1" {
  key_name   = "my-key-pair-1"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "my-instance" {
  ami                         = "ami-0567589d25e06853e"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my-subnet.id
  vpc_security_group_ids      = [aws_security_group.my-security-group.id]
  key_name                    = aws_key_pair.my-key-pair-1.key_name
  associate_public_ip_address = true
  tags = {
    Name = "my-instance"
  }
}

resource "null_resource" "wait_for_instance" {
  depends_on = [aws_instance.my-instance]

  provisioner "local-exec" {
    command = "echo 'Waiting for instance to be not ready...'; sleep 60"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Instance is ready!'"
    ]
  }

  #triggers = {
    #always_run = "${timestamp()}" # This will force the null_resource to run every time
  #}

  triggers = {
    script_hash = filemd5("./my_script.sh") # This will force the null_resource to run if the script changes
  }

  provisioner "file" {
    source      = "./my_script.sh"
    destination = "/tmp/my_script.sh"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.my-instance.public_ip
  }
}
