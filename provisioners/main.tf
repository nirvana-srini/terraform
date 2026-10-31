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
    cidr_blocks = ["0.0.0.0/0"] # least previlege principle would be to restrict this to your IP address, but for lab purposes we will allow all

  }

  # Jenkins web UI
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # least previlege principle would be to restrict this to your IP address, but for lab purposes we will allow all
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my-key-pair" {
  key_name   = "my-key-pair"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}

resource "aws_instance" "example" {
  ami                         = "ami-0567589d25e06853e"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.my-key-pair.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.my-public-subnet-01.id
  vpc_security_group_ids      = [aws_security_group.my-security-group.id]
  tags = {
    Name = "bastion-host"
  }

}


resource "null_resource" "install_jenkins" {
  depends_on = [
    aws_instance.example,
    aws_security_group.my-security-group,
    aws_route_table_association.my-public-subnet-01-association
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(pathexpand("~/.ssh/id_rsa"))
    host        = aws_instance.example.public_ip
    timeout     = "5m"
  }

  # 1. Create script locally
  provisioner "local-exec" {
    command = <<-EOT
      cat > install_jenkins.sh <<'EOF'
      #!/bin/bash
      set -e
      dnf install -y java-21-amazon-corretto git wget fontconfig
      wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
      rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key
      dnf install -y jenkins
      systemctl enable --now jenkins
      EOF
    EOT
  }

  # 2. Copy script to EC2
  provisioner "file" {
    source      = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }

  # 3. Execute script on EC2
  provisioner "remote-exec" {
  inline = [
    "sudo bash /tmp/install_jenkins.sh",
    "echo 'Jenkins URL: http://${aws_instance.example.public_ip}:8080'",
    "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" #not recommended to output password in production, but for lab purposes it's okay
  ]
}
}

output "jenkins_url" {
  value = "http://${aws_instance.example.public_ip}:8080"
}