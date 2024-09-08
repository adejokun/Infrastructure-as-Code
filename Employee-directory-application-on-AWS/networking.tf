
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



# Create a subnets
resource "aws_subnet" "main-01" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "subnet-vpc-dir-app-01"
  }
}

resource "aws_subnet" "main-02" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "subnet-vpc-dir-app-02"
  }
}



# Create a security groups
resource "aws_security_group" "dir-app" {
  name        = "dir-app"
  description = "Allow internet traffic to employee directory application"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "dir-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.dir-app.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.dir-app.id
  
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.dir-app.id
  
  cidr_ipv4   = "18.237.140.160/29" # EC2 Instance Connect service IP addresses in the us-west-2 region (for restricted access)
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

}

resource "aws_vpc_security_group_egress_rule" "egress-all" {
  security_group_id = aws_security_group.dir-app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

