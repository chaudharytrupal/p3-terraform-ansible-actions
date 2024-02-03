data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "projectlt" {
  name = "project-launch-template"

  block_device_mappings {
    device_name = "/dev/sdf"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_groups
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.default_tags,
      {
        "Name" = "${var.prefix}-WebServers"
        "Role" = "Webserver"
      }
    )
  }
  key_name      = var.key_name
  instance_type = var.environment == "prod" ? var.instance_type["prod"] : var.instance_type["staging"]
  image_id      = data.aws_ami.latest_amazon_linux.id

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-launch-template"
    }
  )
}
