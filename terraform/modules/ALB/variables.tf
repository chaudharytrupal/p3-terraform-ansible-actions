variable "name" {
  description = "Name of the load balancer"
}

variable "subnets" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for the load balancer"
  type        = list(string)
}

variable "listener" {
  description = "Listener configuration for the load balancer"
  type        = map(any)
}

variable "target_group_arn" {
  description = "The target group arn"
}