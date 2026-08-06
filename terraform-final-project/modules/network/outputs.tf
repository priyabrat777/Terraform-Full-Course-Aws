output "vpc_id" {
  description = "Primary VPC ID."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Primary VPC CIDR."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "route_table_ids" {
  description = "Route table IDs."
  value = {
    public  = aws_route_table.public.id
    private = [for route_table in aws_route_table.private : route_table.id]
  }
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs."
  value       = [for gateway in aws_nat_gateway.this : gateway.id]
}

output "security_group_ids" {
  description = "Security group IDs by purpose."
  value = {
    alb       = aws_security_group.alb.id
    app       = aws_security_group.app.id
    admin     = aws_security_group.admin.id
    database  = aws_security_group.database.id
    efs       = aws_security_group.efs.id
    lambda    = aws_security_group.lambda.id
    ecs       = aws_security_group.ecs.id
    endpoints = aws_security_group.endpoints.id
  }
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs."
  value = {
    s3        = try(aws_vpc_endpoint.s3[0].id, null)
    interface = { for key, endpoint in aws_vpc_endpoint.interface : key => endpoint.id }
  }
}

output "secondary_vpc_id" {
  description = "Secondary VPC ID when enabled."
  value       = try(aws_vpc.secondary[0].id, null)
}

output "vpc_peering_connection_id" {
  description = "VPC peering connection ID when enabled."
  value       = try(aws_vpc_peering_connection.secondary[0].id, null)
}
