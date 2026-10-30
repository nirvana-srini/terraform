resource "aws_instance" "example" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleInstance"
  }

  provisioner "local-exec" {
    command = "echo 'EC2 created successfully!' > ./hello.txt"
  }
}

