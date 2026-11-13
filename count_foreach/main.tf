
variable "tags" {
  type    = list(string)
  default = ["dev", "test", "prod"]
}

resource "aws_instance" "example" {
  ami           = "ami-0567589d25e06853e"
  instance_type = "t2.micro"
  count         = var.tags != null ? length(var.tags) : 0
  tags = {
    Name = "example-${var.tags[count.index]}"
  }
}