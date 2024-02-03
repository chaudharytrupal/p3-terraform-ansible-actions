output "web_sg_id" {
  description = "The ID of the AWS security group created for web servers"
  value       = aws_security_group.web_sg.id
}
