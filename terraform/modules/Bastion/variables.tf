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
  description = "key name"
  type        = string
}


variable "subnet_id" {
  description = "Subnet Id"
  type        = string
}

variable "security_groups" {
  description = "Subnet Id"
  type        = list(string)

}

variable "prefix" {
  type        = string
  description = "Name prefix"
}

variable "default_tags" {
  default     = {}
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}



