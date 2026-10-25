variable "instance_name" {
  description = "The name of the instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The type of the instance"
  type        = string
  default     = ""
}

variable "ami" {
  description = "The AMI ID for the instance"
  type        = string
  default     = ""
}

variable "az" {
  description = "The availability zone for the instance"
  type        = string
  default     = ""
}