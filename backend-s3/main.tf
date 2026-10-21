resource "aws_instance" "example" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t2.micro"

  tags = {
    Name = "TF Instance"
  }
}
