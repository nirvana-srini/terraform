module "test" {
  source        = "../../ec2"
  ami           = "ami-0567589d25e06853e"
  instance_type = "t2.micro"
  az            = "us-east-1a"
  instance_name = "test-instance"
}