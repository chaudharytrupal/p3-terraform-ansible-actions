output "public_subnet_ids" {
  value = module.vpc-stag.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc-stag.private_subnet_ids
}

output "vpc_id" {
  value = module.vpc-stag.vpc_id
}

output "public_ip_bastion" {
  value = module.bastion.public_ip_bastion
}

output "load_balancer_dns" {
  value = module.ALB.dns_name
}