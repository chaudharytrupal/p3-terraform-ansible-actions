resource "aws_autoscaling_group" "acsprojectasg" {
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_id
  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true
  wait_for_capacity_timeout = "0"

  target_group_arns = [var.target_group_arn]

  lifecycle {
    create_before_destroy = true
  }
}

# AWS Auto Scaling Policy for Scaling Out
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "ScaleOutPolicy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # 5 minutes cooldown
  autoscaling_group_name = aws_autoscaling_group.acsprojectasg.name
}

# AWS Auto Scaling Policy for Scaling In
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "ScaleInPolicy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 # 5 minutes cooldown
  autoscaling_group_name = aws_autoscaling_group.acsprojectasg.name
}

# AWS CloudWatch Alarm for Scaling Out
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "CPUUtilizationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 10 # Scale out if CPU utilization is above 10%
  alarm_description   = "Scale out if CPU utilization is above 10% for 2 consecutive periods"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.acsprojectasg.name
  }

  actions_enabled = true

  # Scale out policy
  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]
}

# AWS CloudWatch Alarm for Scaling In
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name          = "CPUUtilizationLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300 # 5 minutes
  statistic           = "Average"
  threshold           = 5 # Scale in if CPU utilization is below 5%
  alarm_description   = "Scale in if CPU utilization is below 5% for 2 consecutive periods"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.acsprojectasg.name
  }

  actions_enabled = true

  # Scale in policy
  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]
}