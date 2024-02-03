variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling Group."
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group."
}

variable "max_size" {
  description = "The maximum size of the Auto Scaling Group."
}
variable "launch_template_id" {
  description = "The id of the launch template."
}

variable "subnet_id" {
  description = "The id of the subnets."
  type        = list(string)
}

variable "target_group_arn" {
  description = "The target group arn"
}