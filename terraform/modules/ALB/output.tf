# Output the DNS name of the load balancer
output "dns_name" {
  value       = aws_lb.application.dns_name
  description = "The DNS name of the application load balancer"
}