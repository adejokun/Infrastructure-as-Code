## Create a VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "vpc-ecs-dir-app"
  }
}


## Create an internet gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw-ecs-dir-app"
  }
}


## Create route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = aws_vpc.main.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "rt-ecs-dir-app"
  }
}

# create route table association with subnets
resource "aws_route_table_association" "subnet-main-01" {
  subnet_id      = aws_subnet.main-01.id
  route_table_id = aws_route_table.rt.id
 
}

resource "aws_route_table_association" "subnet-main-02" {
  subnet_id      = aws_subnet.main-02.id
  route_table_id = aws_route_table.rt.id
  
}

## Create subnets
resource "aws_subnet" "main-01" { # public subnet-01 for load balancer 
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "subnet-vpc-alb-01"
  }
}

resource "aws_subnet" "main-02" { # public subnet-02 for load balancer 
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "subnet-vpc-alb-02"
  }
}

resource "aws_subnet" "private-01" { # private subnet-01 for ecs service
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "subnet-vpc-ecs-dir-app-01"
  }
}

resource "aws_subnet" "private-02" { # private subnet-02 for ecs service
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "subnet-vpc-dir-app-02"
  }
}


## Create security group - load balancer
resource "aws_security_group" "alb" {
  name        = "alb-dir-app"
  description = "Allow internet traffic to employee directory application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "sg-alb-dir-app"
  }
}


resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.alb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_vpc_security_group_egress_rule" "egress-all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

## Create security group - ecs service
resource "aws_security_group" "ecs-dir-app" {
  name        = "ecs-dir-app"
  description = "Allow internet traffic to employee directory application via load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "ecs-dir-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs-dir-app" {
  security_group_id = aws_security_group.ecs-dir-app.id
  
  referenced_security_group_id = aws_security_group.alb.id # permits traffic from the load balancer
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_egress_rule" "ecs-dir-app" {
  security_group_id = aws_security_group.ecs-dir-app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

## Creates a load balancer
resource "aws_lb" "ecs-dir-app" {
  name               = "ecs-lb-dir-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.main-01.id, aws_subnet.main-02.id]

}

resource "aws_lb_listener" "dir-app" {
  load_balancer_arn = aws_lb.ecs-dir-app.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-dir-app.arn
  }
}

resource "aws_lb_target_group" "ecs-dir-app" {
  name     = "ecs-tg-dir-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled = true
  }
}




