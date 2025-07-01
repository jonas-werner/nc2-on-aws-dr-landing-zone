# VPC 1 Outputs
output "vpc1_id" {
  description = "The ID of VPC 1"
  value       = aws_vpc.vpc1.id
}

output "vpc1_subnets" {
  description = "Subnets in VPC 1"
  value = {
    "${aws_subnet.vpc1_public.tags.Name}" = aws_subnet.vpc1_public.id
    "${aws_subnet.vpc1_private_metal.tags.Name}" = aws_subnet.vpc1_private_metal.id
    "${aws_subnet.vpc1_private_pc.tags.Name}" = aws_subnet.vpc1_private_pc.id
    "${aws_subnet.vpc1_private_flow.tags.Name}" = aws_subnet.vpc1_private_flow.id
  }
}

# Separator
output "separator" {
  value = "----------------------------------------"
}

# VPC 2 Outputs
output "vpc2_id" {
  description = "The ID of VPC 2"
  value       = aws_vpc.vpc2.id
}

output "vpc2_subnets" {
  description = "Subnets in VPC 2"
  value = {
    "${aws_subnet.vpc2_public.tags.Name}" = aws_subnet.vpc2_public.id
    "${aws_subnet.vpc2_private_metal.tags.Name}" = aws_subnet.vpc2_private_metal.id
    "${aws_subnet.vpc2_private_pc.tags.Name}" = aws_subnet.vpc2_private_pc.id
    "${aws_subnet.vpc2_private_flow.tags.Name}" = aws_subnet.vpc2_private_flow.id
  }
} 