# VPC Configuration for the EKS
resource "aws_vpc" "eks_vpc" {
  # CIDR block for the VPC
  cidr_block           = "10.0.0.0/16"
  # Enabling DNS support and hostnames within the VPC
  enable_dns_support   = true  
  enable_dns_hostnames = true
  tags = {
    "Name" = "eks_vpc"
  }
}

# Subnet Configuration - configuration for two subnets in different availability zones for high availability
resource "aws_subnet" "eks_subnet_a" {
  # Associating the subnet with the VPC
  vpc_id                  = aws_vpc.eks_vpc.id
  # CIDR block for the subnet
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  # Enabling public IP assignment for instances in this subnet
  map_public_ip_on_launch = true
  tags = {
    "Name" = "eks_subnet_a" # Tag the subnet with the 'eks_subnet_a' name
  }
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "eks_subnet_b"
  }
}

# Security group for the EKS cluster, defining the allowed inbound and outbound traffic
resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.eks_vpc.id
  name        = "eks_security_group"
  description = "Security group for EKS cluster"

  # Allowing inbound HTTPS traffic on port 443
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all inbound HTTPS traffic
  }
}

# Security Group Rule for Ingress Traffic from Load Balancer
resource "aws_security_group_rule" "eks_node_group_lb_ingress" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  source_security_group_id = "sg-043593bfc9b369acf"  # The Load Balancer's Security Group ID
  security_group_id = aws_security_group.eks_security_group.id
  description       = "Allow traffic from LB to EKS nodes on port 5000"
}

# Default Egress Rule for Security Group
resource "aws_security_group_rule" "eks_security_group_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_security_group.id
}

/*
resource "aws_security_group_rule" "eks_security_group_ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["147.235.203.221/32"]  # My specific IP address
  # cidr_blocks       = ["0.0.0.0/0"]  # Allow from all IPv4 addresses
  ipv6_cidr_blocks  = ["::/0"]       # Allow from all IPv6 addresses
  security_group_id = aws_security_group.eks_security_group.id
  description       = "Temporary SSH access"
}
*/

# Internet Gateway for VPC
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-vpc-internet-gateway"
  }
}

# Route Table for VPC
resource "aws_route_table" "eks_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks_route_table"
  }
}

# Route Table Associations
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.eks_subnet_a.id
  route_table_id = aws_route_table.eks_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.eks_subnet_b.id
  route_table_id = aws_route_table.eks_rt.id
}
