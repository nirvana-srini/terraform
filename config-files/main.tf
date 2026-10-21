resource "aws_instance" "example" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t3.medium"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Example Instance"
  }
}
