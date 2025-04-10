# output.tf

output "vpc_id" {
  value = aws_vpc.custom_vpc.id
  description = "ID of the custom VPC"
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id,
  ]
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id,
  ]
  description = "IDs of the private subnets"
}

output "internet_gateway_id" {
  value = aws_internet_gateway.custom_igw.id
  description = "ID of the internet gateway"
}

output "nat_gateway_id" {
  value = aws_nat_gateway.custom_nat.id
  description = "ID of the NAT gateway"
}

output "security_group_id" {
  value = aws_security_group.custom_sg.id
  description = "ID of the security group"
}

output "key_pair_name" {
  value = aws_key_pair.spain_deployment_key_pair.key_name
  description = "Name of the key pair"
}

output "launch_template_id" {
  value = aws_launch_template.deployment_template.id
  description = "ID of the launch template"
}

output "load_balancer_arn" {
  value = aws_lb.deployment_loadbalancer.arn
  description = "ARN of the application load balancer"
}

output "load_balancer_dns_name" {
  value = aws_lb.deployment_loadbalancer.dns_name
  description = "DNS name of the application load balancer"
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
  description = "ARN of the target group"
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.deployment_scaling_group.name
  description = "Name of the auto scaling group"
}

output "database_instance_id" {
  value = aws_instance.database_instance.id
  description = "ID of the database instance"
}

output "efs_file_system_id" {
  value = aws_efs_file_system.app_file.id
  description = "ID of the EFS file system"
}

output "cdn_distribution_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
  description = "Domain name of the CloudFront distribution"
}
