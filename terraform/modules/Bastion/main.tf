# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.environment == "prod" ? var.instance_type["prod"] : var.instance_type["staging"]
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  security_groups             = var.security_groups
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-bastion"
      "Role" = "Bastion"
    }
  )
}
