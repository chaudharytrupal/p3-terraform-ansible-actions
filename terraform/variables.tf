# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default = {
    prod    = ["10.250.1.0/24", "10.250.2.0/24", "10.250.3.0/24"]
    staging = ["10.200.1.0/24", "10.200.2.0/24", "10.200.3.0/24"]
  }
  type        = map(list(string))
  description = "Public Subnet CIDRs"
}

# Provision private subnets in custom VPC
variable "private_subnet_cidrs" {
  default = {
    prod    = ["10.250.11.0/24", "10.250.12.0/24", "10.250.13.0/24"]
    staging = ["10.200.11.0/24", "10.200.12.0/24", "10.200.13.0/24"]
  }
  type        = map(list(string))
  description = "Private Subnet CIDRs"
}

# VPC CIDR range
variable "vpc_cidr" {
  type        = map(string)
  description = "VPC CIDR range"
  default = {
    prod    = "10.250.0.0/16"
    staging = "10.200.0.0/16"
  }
}

# Availability zones
variable "availability_zones" {
  default     = ["us-east-1b", "us-east-1c", "us-east-1d"]
  type        = list(string)
  description = "Availability zones for the VPC"
}

# Variable to signal the current environment 
variable "env" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}

variable "bucketname" {
  description = "S3 bucket name"
  type        = string
  default     = "project-acs730-breezy-archery-tc"
}