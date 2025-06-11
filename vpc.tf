# VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc1_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_prefix}-vpc1"
  }
}

# Default Route Table for VPC 1
resource "aws_default_route_table" "vpc1_default" {
  default_route_table_id = aws_vpc.vpc1.default_route_table_id
  tags = {
    Name = "${var.project_prefix}-vpc1-default-rt"
  }
}

# VPC 1 Subnets
resource "aws_subnet" "vpc1_public" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block             = cidrsubnet(var.vpc1_cidr, 8, 1)
  availability_zone      = var.vpc1_az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_prefix}-vpc1-public"
  }
}

resource "aws_subnet" "vpc1_private_metal" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block       = cidrsubnet(var.vpc1_cidr, 8, 2)
  availability_zone = var.vpc1_az
  tags = {
    Name = "${var.project_prefix}-vpc1-private-metal"
  }
}

resource "aws_subnet" "vpc1_private_pc" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block       = cidrsubnet(var.vpc1_cidr, 8, 3)
  availability_zone = var.vpc1_az
  tags = {
    Name = "${var.project_prefix}-vpc1-private-pc"
  }
}

resource "aws_subnet" "vpc1_private_flow" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block       = cidrsubnet(var.vpc1_cidr, 8, 4)
  availability_zone = var.vpc1_az
  tags = {
    Name = "${var.project_prefix}-vpc1-private-flow"
  }
}

# VPC 2
resource "aws_vpc" "vpc2" {
  provider            = aws.vpc2
  cidr_block         = var.vpc2_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_prefix}-vpc2"
  }
}

# Default Route Table for VPC 2
resource "aws_default_route_table" "vpc2_default" {
  provider               = aws.vpc2
  default_route_table_id = aws_vpc.vpc2.default_route_table_id
  tags = {
    Name = "${var.project_prefix}-vpc2-default-rt"
  }
}

# VPC 2 Subnets
resource "aws_subnet" "vpc2_public" {
  provider                = aws.vpc2
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block             = cidrsubnet(var.vpc2_cidr, 8, 1)
  availability_zone      = var.vpc2_az
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_prefix}-vpc2-public"
  }
}

resource "aws_subnet" "vpc2_private_metal" {
  provider          = aws.vpc2
  vpc_id            = aws_vpc.vpc2.id
  cidr_block       = cidrsubnet(var.vpc2_cidr, 8, 2)
  availability_zone = var.vpc2_az
  tags = {
    Name = "${var.project_prefix}-vpc2-private-metal"
  }
}

resource "aws_subnet" "vpc2_private_pc" {
  provider          = aws.vpc2
  vpc_id            = aws_vpc.vpc2.id
  cidr_block       = cidrsubnet(var.vpc2_cidr, 8, 3)
  availability_zone = var.vpc2_az
  tags = {
    Name = "${var.project_prefix}-vpc2-private-pc"
  }
}

resource "aws_subnet" "vpc2_private_flow" {
  provider          = aws.vpc2
  vpc_id            = aws_vpc.vpc2.id
  cidr_block       = cidrsubnet(var.vpc2_cidr, 8, 4)
  availability_zone = var.vpc2_az
  tags = {
    Name = "${var.project_prefix}-vpc2-private-flow"
  }
} 