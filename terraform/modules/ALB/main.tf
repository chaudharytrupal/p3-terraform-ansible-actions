resource "aws_lb" "application" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = var.security_groups

  enable_deletion_protection = false # Set to true if you want to enable deletion protection

  enable_cross_zone_load_balancing = true

  enable_http2 = true
  idle_timeout = 60


}

resource "aws_lb_listener" "application" {
  load_balancer_arn = aws_lb.application.arn
  port              = var.listener["port"]
  protocol          = var.listener["protocol"]

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }

}

resource "aws_lb_listener_rule" "application" {
  listener_arn = aws_lb_listener.application.arn

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


