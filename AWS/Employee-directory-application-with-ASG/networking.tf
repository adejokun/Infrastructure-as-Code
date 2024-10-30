
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "vpc-dir-app"
  }
}


# create an internet gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw-dir-app"
  }
}


# create route table
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
    Name = "rt-dir-app"
  }
}



# create route table association with subnets
resource "aws_route_table_association" "subnet-main-01" {
  subnet_id      = aws_subnet.main-01.id
  route_table_id = aws_route_table.rt.id

  depends_on = [aws_subnet.main-01]
}

resource "aws_route_table_association" "subnet-main-02" {
  subnet_id      = aws_subnet.main-02.id
  route_table_id = aws_route_table.rt.id

  depends_on = [aws_subnet.main-02]
}

resource "aws_route_table_association" "subnet-private-01" {
  subnet_id      = aws_subnet.private-01.id
  route_table_id = aws_route_table.rt.id

  depends_on = [aws_subnet.private-01]
}

resource "aws_route_table_association" "subnet-private-02" {
  subnet_id      = aws_subnet.private-02.id
  route_table_id = aws_route_table.rt.id

  depends_on = [aws_subnet.private-02]
}


# Create subnets
resource "aws_subnet" "main-01" {  # subnet-01 for load balancer
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "subnet-vpc-elb-01"
  }
}

resource "aws_subnet" "main-02" { # subnet-02 for load balancer
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "subnet-vpc-elb-02"
  }
}

resource "aws_subnet" "private-01" { # subnet-01 for autoscaling group
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "subnet-vpc-dir-app-01"
  }
}

resource "aws_subnet" "private-02" { # subnet-02 for autoscaling group
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "subnet-vpc-dir-app-02"
  }
}

# Create load balancer security group
resource "aws_security_group" "elb" {
  name        = "dir-app-elb"
  description = "Allow internet traffic to employee directory application via application load balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dir-app-elb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.elb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.elb.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_vpc_security_group_egress_rule" "egress-all" {
  security_group_id = aws_security_group.elb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Create EC2/autoscaling-group security group
resource "aws_security_group" "dir-app" {
  name        = "dir-app-ec2"
  description = "Allow SSH to ec2"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dir-app-ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.dir-app.id
  
  cidr_ipv4   = "18.237.140.160/29" # EC2 Instance Connect service IP addresses in the us-west-2 region (for restricted access)
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

}

resource "aws_vpc_security_group_ingress_rule" "elb-traffic" {
  security_group_id = aws_security_group.dir-app.id
  
  referenced_security_group_id = aws_security_group.elb.id # permits traffic from the load balancer
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_egress_rule" "ec2-egress" {
  security_group_id = aws_security_group.dir-app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}