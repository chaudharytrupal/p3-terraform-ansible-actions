output "autoscaling_group_id" {
  description = "The ID of the Auto Scaling Group."
  value       = aws_autoscaling_group.acsprojectasg.id
}
