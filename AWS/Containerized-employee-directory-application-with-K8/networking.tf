
## Create a VPC
resource "aws_vpc" "k8-t-vpc" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "k8-t-vpc"
  }
}


## create an internet gateway for VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.k8-t-vpc.id

  tags = {
    Name = "k8-t-gw"
  }
}

## NAT Gateway
# create elastic ip for NAT gateway
resource "aws_eip" "NATgw" {
  domain   = "vpc"

  tags = {
    Name = "k8-t-eip-NATgw"
  }
}

# create NAT gateway
resource "aws_nat_gateway" "k8-t-NATgw" {
  allocation_id     = aws_eip.NATgw.id
  connectivity_type = "public"
  subnet_id         = aws_subnet.public-NATgw.id

  tags = {
    Name = "k8-t-NATgw"
  }

  depends_on = [aws_internet_gateway.gw]
}


## Route Tables
# create route table for public subnet
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.k8-t-vpc.id

  route {
    cidr_block = aws_vpc.k8-t-vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "k8-t-rt-public"
  }
}

# create route table for private subnet
resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.k8-t-vpc.id

  route {
    cidr_block = aws_vpc.k8-t-vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8-t-NATgw.id
  }

  tags = {
    Name = "k8-t-rt-private"
  }
}

# create route table association with subnets
resource "aws_route_table_association" "public-01" {
  subnet_id      = aws_subnet.public-01.id
  route_table_id = aws_route_table.rt-public.id

}

resource "aws_route_table_association" "public-02" {
  subnet_id      = aws_subnet.public-02.id
  route_table_id = aws_route_table.rt-public.id

}

resource "aws_route_table_association" "public-NATgw" {
  subnet_id      = aws_subnet.public-NATgw.id
  route_table_id = aws_route_table.rt-public.id

}

resource "aws_route_table_association" "private-01" {
  subnet_id      = aws_subnet.private-01.id
  route_table_id = aws_route_table.rt-private.id

}

resource "aws_route_table_association" "private-02" {
  subnet_id      = aws_subnet.private-02.id
  route_table_id = aws_route_table.rt-private.id

}


## Create subnets
resource "aws_subnet" "public-01" {  # subnet-01 for EKS Cluster
  vpc_id     = aws_vpc.k8-t-vpc.id
  cidr_block = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "k8-t-public-01"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-02" { # subnet-02 for EKS Cluster
  vpc_id     = aws_vpc.k8-t-vpc.id
  cidr_block = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "k8-t-public-02"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public-NATgw" { # subnet for NAT Gateway
  vpc_id     = aws_vpc.k8-t-vpc.id
  cidr_block = "10.1.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "k8-t-public-NATgw" 
  }
}

resource "aws_subnet" "private-01" { # subnet-01 for managed node group
  vpc_id     = aws_vpc.k8-t-vpc.id
  cidr_block = "10.1.4.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "k8-t-private-01"
    "kubernetes.io/role/internal-elb" = "1"
  }
  
}

resource "aws_subnet" "private-02" { # subnet-02 for managed node group
  vpc_id     = aws_vpc.k8-t-vpc.id
  cidr_block = "10.1.5.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "k8-t-private-02"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

## Create EKS node group security group
resource "aws_security_group" "node-grp" {
  name        = "k8-t-node-grp"
  description = "Allows remote access to node group"
  vpc_id      = aws_vpc.k8-t-vpc.id

  tags = {
    Name = "k8-t-node-grp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.node-grp.id
  
  cidr_ipv4   = "0.0.0.0/0" # restrict block for production workloads
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22

}

resource "aws_vpc_security_group_egress_rule" "egress-all" {
  security_group_id = aws_security_group.node-grp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


