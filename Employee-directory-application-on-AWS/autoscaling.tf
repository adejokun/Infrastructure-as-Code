
# create cloudwatch metric alarm and scaling policy
# scale up
resource "aws_autoscaling_policy" "scale-up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.dir-app.name
}

resource "aws_cloudwatch_metric_alarm" "scale-up" {
  alarm_name          = "alarm-scale-up-dir-app"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dir-app.name
  }

  alarm_description = "Scales up the employee directory application"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]
}

# create cloudwatch metric alarm and scaling policy
# scale down
resource "aws_autoscaling_policy" "scale-down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.dir-app.name
}

resource "aws_cloudwatch_metric_alarm" "scale-down" {
  alarm_name          = "alarm-scale-down-dir-app"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.dir-app.name
  }

  alarm_description = "Scales down the employee directory application"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]
}

# creates a load balancer
resource "aws_lb" "dir-app" {
  name               = "lb-dir-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb.id]
  subnets            = [aws_subnet.main-01.id, aws_subnet.main-02.id]

}

resource "aws_lb_listener" "dir-app" {
  load_balancer_arn = aws_lb.dir-app.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dir-app.arn
  }
}

resource "aws_lb_target_group" "dir-app" {
  name     = "tg-dir-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled = true
  }
}

resource "aws_autoscaling_attachment" "dir-app" {
  autoscaling_group_name = aws_autoscaling_group.dir-app.id
  lb_target_group_arn    = aws_lb_target_group.dir-app.arn
}


# create IAM role
resource "aws_iam_role" "ec2" {
  name = "ec2-dir-app"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  
}

# create an IAM role policy attachment - Amazon S3
resource "aws_iam_role_policy_attachment" "ec2-S3" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# create an IAM role policy attachment - DynamoDB
resource "aws_iam_role_policy_attachment" "ec2-DynamoDB" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# create an IAM role instance profile
resource "aws_iam_instance_profile" "ec2" {
  name = "instance-profile-dir-app"
  role = aws_iam_role.ec2.name
}



# creates a launch template
resource "aws_launch_template" "dir-app" {
  name                   = "template-dir-app"
  image_id               = "ami-02d3770deb1c746ec"
  instance_type          = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.dir-app.id]
    subnet_id = aws_subnet.private-01.id
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  user_data= base64encode("${file("script.sh")}")
  
}


# creates an autoscaling group
resource "aws_autoscaling_group" "dir-app" {
  name = "ASG-dir-app"
  vpc_zone_identifier = [aws_subnet.private-01.id, aws_subnet.private-02.id]
  desired_capacity   = 2
  max_size           = 4
  min_size           = 1
  health_check_type = "ELB"
  target_group_arns = [aws_lb_target_group.dir-app.arn]

  launch_template {
    id      = aws_launch_template.dir-app.id
    version = "$Latest"
  }
}

