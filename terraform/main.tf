terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}
# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "./globalvars"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = local.prefix
}

# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = local.name_prefix
  public_key = file("key.pub")
}

# Module to deploy basic networking 
module "vpc-stag" {
  source              = "./modules/networking"
  env                 = var.env
  vpc_cidr            = var.env == "prod" ? var.vpc_cidr["prod"] : var.vpc_cidr["staging"]
  public_cidr_blocks  = var.env == "prod" ? var.public_subnet_cidrs["prod"] : var.public_subnet_cidrs["staging"]
  private_cidr_blocks = var.env == "prod" ? var.private_subnet_cidrs["prod"] : var.private_subnet_cidrs["staging"]
  prefix              = local.name_prefix
  default_tags        = local.default_tags
  availability_zones  = var.availability_zones
}

module "bastion" {
  source          = "./modules/Bastion"
  prefix          = local.name_prefix
  default_tags    = local.default_tags
  subnet_id       = module.vpc-stag.public_subnet_ids[0]
  security_groups = [module.SG.web_sg_id]
  environment     = var.env
  key_name        = aws_key_pair.web_key.key_name

}

module "ALB" {
  source           = "./modules/ALB"
  name             = "my-alb"
  subnets          = [module.vpc-stag.public_subnet_ids[0], module.vpc-stag.public_subnet_ids[1], module.vpc-stag.public_subnet_ids[2]]
  security_groups  = [module.SG.web_sg_id]
  target_group_arn = aws_lb_target_group.my_target_group.arn
  listener = {
    port                = 80
    protocol            = "HTTP"
    default_action_type = "fixed-response"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc-stag.vpc_id
  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

module "LaunchTemplate" {
  source          = "./modules/LaunchTemplate"
  key_name        = aws_key_pair.web_key.key_name
  security_groups = [module.SG.web_sg_id]
  prefix          = local.name_prefix
  default_tags    = local.default_tags
  environment     = var.env

}

# Additional resources and configurations as needed
module "ASG" {
  source             = "./modules/ASG"
  desired_capacity   = 3
  min_size           = 3
  max_size           = 4
  launch_template_id = module.LaunchTemplate.launch_template_id
  subnet_id          = [module.vpc-stag.private_subnet_ids[0], module.vpc-stag.private_subnet_ids[1], module.vpc-stag.private_subnet_ids[2]]
  target_group_arn   = aws_lb_target_group.my_target_group.arn
}

module "SG" {
  source = "./modules/SG"
  vpc_id = module.vpc-stag.vpc_id
}

module "S3" {
  source     = "./modules/S3"
  bucketname = var.bucketname
}
