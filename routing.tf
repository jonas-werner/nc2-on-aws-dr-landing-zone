# VPC 1 Route Tables
resource "aws_route_table" "vpc1_public" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.project_prefix}-vpc1-public-rt"
  }
}

# VPC 2 Route Tables
resource "aws_route_table" "vpc2_public" {
  provider = aws.vpc2
  vpc_id   = aws_vpc.vpc2.id
  tags = {
    Name = "${var.project_prefix}-vpc2-public-rt"
  }
}

# Internet Gateways
resource "aws_internet_gateway" "vpc1_igw" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "${var.project_prefix}-vpc1-igw"
  }
}

resource "aws_internet_gateway" "vpc2_igw" {
  provider = aws.vpc2
  vpc_id   = aws_vpc.vpc2.id
  tags = {
    Name = "${var.project_prefix}-vpc2-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "vpc1_nat_eip" {
  domain = "vpc"
  tags = {
    Name = "${var.project_prefix}-vpc1-nat-eip"
  }
}

resource "aws_eip" "vpc2_nat_eip" {
  provider = aws.vpc2
  domain   = "vpc"
  tags = {
    Name = "${var.project_prefix}-vpc2-nat-eip"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "vpc1_nat" {
  allocation_id = aws_eip.vpc1_nat_eip.id
  subnet_id     = aws_subnet.vpc1_public.id
  tags = {
    Name = "${var.project_prefix}-vpc1-nat"
  }
  depends_on = [aws_internet_gateway.vpc1_igw]
}

resource "aws_nat_gateway" "vpc2_nat" {
  provider      = aws.vpc2
  allocation_id = aws_eip.vpc2_nat_eip.id
  subnet_id     = aws_subnet.vpc2_public.id
  tags = {
    Name = "${var.project_prefix}-vpc2-nat"
  }
  depends_on = [aws_internet_gateway.vpc2_igw]
}

# Route Table Associations
resource "aws_route_table_association" "vpc1_public" {
  subnet_id      = aws_subnet.vpc1_public.id
  route_table_id = aws_route_table.vpc1_public.id
}

resource "aws_route_table_association" "vpc2_public" {
  provider       = aws.vpc2
  subnet_id      = aws_subnet.vpc2_public.id
  route_table_id = aws_route_table.vpc2_public.id
}

# Public Subnet Routes (Internet Gateway)
resource "aws_route" "vpc1_public_igw" {
  route_table_id         = aws_route_table.vpc1_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc1_igw.id
}

resource "aws_route" "vpc2_public_igw" {
  provider               = aws.vpc2
  route_table_id         = aws_route_table.vpc2_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc2_igw.id
}

# Private Subnet Routes (NAT Gateway)
resource "aws_route" "vpc1_private_nat" {
  route_table_id         = aws_vpc.vpc1.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc1_nat.id
}

resource "aws_route" "vpc2_private_nat" {
  provider               = aws.vpc2
  route_table_id         = aws_vpc.vpc2.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.vpc2_nat.id
}

# VPC Peering Configuration
resource "aws_vpc_peering_connection" "vpc_peering" {
  count       = var.peering_type == "vpc" ? 1 : 0
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  peer_region = var.vpc1_region == var.vpc2_region ? null : var.vpc2_region
  auto_accept = var.vpc1_region == var.vpc2_region

  tags = {
    Name = "${var.project_prefix}-vpc-peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  count                     = var.peering_type == "vpc" && var.vpc1_region != var.vpc2_region ? 1 : 0
  provider                  = aws.vpc2
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
  auto_accept              = true

  tags = {
    Name = "${var.project_prefix}-vpc-peering-accepter"
  }
}

# VPC Peering Routes
resource "aws_route" "vpc1_to_vpc2" {
  count                     = var.peering_type == "vpc" ? 1 : 0
  route_table_id            = aws_vpc.vpc1.default_route_table_id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

resource "aws_route" "vpc2_to_vpc1" {
  count                     = var.peering_type == "vpc" ? 1 : 0
  provider                  = aws.vpc2
  route_table_id            = aws_vpc.vpc2.default_route_table_id
  destination_cidr_block    = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

# VPC Peering Routes for Public Subnets
resource "aws_route" "vpc1_public_to_vpc2" {
  count                     = var.peering_type == "vpc" ? 1 : 0
  route_table_id            = aws_route_table.vpc1_public.id
  destination_cidr_block    = var.vpc2_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

resource "aws_route" "vpc2_public_to_vpc1" {
  count                     = var.peering_type == "vpc" ? 1 : 0
  provider                  = aws.vpc2
  route_table_id            = aws_route_table.vpc2_public.id
  destination_cidr_block    = var.vpc1_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering[0].id
}

# Transit Gateway Configuration
resource "aws_ec2_transit_gateway" "tgw1" {
  count = var.peering_type == "tgw" ? 1 : 0
  description = "${var.project_prefix} Transit Gateway in ${var.vpc1_region}"
  tags = {
    Name = "${var.project_prefix}-tgw-${var.vpc1_region}"
  }
}

resource "aws_ec2_transit_gateway" "tgw2" {
  count       = var.peering_type == "tgw" && var.vpc1_region != var.vpc2_region ? 1 : 0
  provider    = aws.vpc2
  description = "${var.project_prefix} Transit Gateway in ${var.vpc2_region}"
  tags = {
    Name = "${var.project_prefix}-tgw-${var.vpc2_region}"
  }
}

# TGW Peering for cross-region setup
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  count = var.peering_type == "tgw" && var.vpc1_region != var.vpc2_region ? 1 : 0
  
  peer_region             = var.vpc2_region
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw2[0].id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw1[0].id
  
  tags = {
    Name = "${var.project_prefix}-tgw-peering"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  count = var.peering_type == "tgw" && var.vpc1_region != var.vpc2_region ? 1 : 0
  
  provider                      = aws.vpc2
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering[0].id
  
  tags = {
    Name = "${var.project_prefix}-tgw-peering-accepter"
  }
}

# TGW VPC Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_attachment" {
  count              = var.peering_type == "tgw" ? 1 : 0
  subnet_ids         = [aws_subnet.vpc1_private_metal.id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw1[0].id
  vpc_id             = aws_vpc.vpc1.id
  tags = {
    Name = "${var.project_prefix}-vpc1-tgw-attachment"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_attachment" {
  count              = var.peering_type == "tgw" ? 1 : 0
  provider           = aws.vpc2
  subnet_ids         = [aws_subnet.vpc2_private_metal.id]
  transit_gateway_id = var.vpc1_region == var.vpc2_region ? aws_ec2_transit_gateway.tgw1[0].id : aws_ec2_transit_gateway.tgw2[0].id
  vpc_id             = aws_vpc.vpc2.id
  tags = {
    Name = "${var.project_prefix}-vpc2-tgw-attachment"
  }
}

# TGW Routes
resource "aws_ec2_transit_gateway_route" "tgw1_to_vpc2" {
  count = var.peering_type == "tgw" && var.vpc1_region != var.vpc2_region ? 1 : 0
  
  destination_cidr_block         = var.vpc2_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw1[0].association_default_route_table_id
  
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter
  ]
}

resource "aws_ec2_transit_gateway_route" "tgw2_to_vpc1" {
  count = var.peering_type == "tgw" && var.vpc1_region != var.vpc2_region ? 1 : 0
  
  provider                       = aws.vpc2
  destination_cidr_block         = var.vpc1_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw2[0].association_default_route_table_id
  
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter
  ]
}

# VPC Routes for TGW
resource "aws_route" "vpc1_to_tgw" {
  count                  = var.peering_type == "tgw" ? 1 : 0
  route_table_id         = aws_vpc.vpc1.default_route_table_id
  destination_cidr_block = var.vpc2_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw1[0].id
}

resource "aws_route" "vpc2_to_tgw" {
  count                  = var.peering_type == "tgw" ? 1 : 0
  provider               = aws.vpc2
  route_table_id         = aws_vpc.vpc2.default_route_table_id
  destination_cidr_block = var.vpc1_cidr
  transit_gateway_id     = var.vpc1_region == var.vpc2_region ? aws_ec2_transit_gateway.tgw1[0].id : aws_ec2_transit_gateway.tgw2[0].id
}

# VPC Public Routes for TGW
resource "aws_route" "vpc1_public_to_tgw" {
  count                  = var.peering_type == "tgw" ? 1 : 0
  route_table_id         = aws_route_table.vpc1_public.id
  destination_cidr_block = var.vpc2_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw1[0].id
}

resource "aws_route" "vpc2_public_to_tgw" {
  count                  = var.peering_type == "tgw" ? 1 : 0
  provider               = aws.vpc2
  route_table_id         = aws_route_table.vpc2_public.id
  destination_cidr_block = var.vpc1_cidr
  transit_gateway_id     = var.vpc1_region == var.vpc2_region ? aws_ec2_transit_gateway.tgw1[0].id : aws_ec2_transit_gateway.tgw2[0].id
} 