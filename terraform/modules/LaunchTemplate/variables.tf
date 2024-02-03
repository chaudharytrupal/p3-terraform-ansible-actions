
variable "instance_type" {
  description = "The type of EC2 instance."
  type        = map(string)
  default = {
    prod    = "t3.medium"
    staging = "t3.small"
  }
}
variable "environment" {
  description = "current environment"
  type        = string
}

variable "key_name" {
  description = "ssh key"
  type        = string
}

variable "security_groups" {
  description = "Security Group name"
  type        = list(string)

}

# variable "subnets"{
#   description = "Subnet Id"
#   type        = list(string)
# }

variable "availability_zones" {
  type    = list(string)
  default = ["us-west-1a", "us-west-1b", "us-west-1c"]
}

# Name prefix
variable "prefix" {
  type        = string
  description = "Name prefix"
}

# Default tags
variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}
