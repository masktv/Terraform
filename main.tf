provider "aws" {
  region = var.region
}

# creating VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "custom-vpc"
  }
}

# creating 3 public subnet for 3 availability_zone
resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.pub_sub_cidr_a
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "az-1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.pub_sub_cidr_b
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "az-2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  cidr_block        = var.pub_sub_cidr_c
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "az-3"
  }
}

# crerating 3 private subnet for 3 availability_zone
resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.priv_sub_cidr_a
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "az-1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.priv_sub_cidr_b
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "az-2"
  }
}
resource "aws_subnet" "private_subnet_3" {
  cidr_block        = var.priv_sub_cidr_c
  vpc_id            = aws_vpc.custom_vpc.id
  availability_zone = "ap-southeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "az-3"
  }
}

# creating internet gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom-igw"
  }
}

# creating route table for igw
resource "aws_route_table" "custom_igw_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom-igw-route-table"
  }
}

# creating route to internet gateway
resource "aws_route" "igw_routs" {
  route_table_id         = aws_route_table.custom_igw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.custom_igw.id
}

# subnet assosiation for igw
resource "aws_route_table_association" "to_public_route_a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.custom_igw_route_table.id
}
resource "aws_route_table_association" "to_public_route_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.custom_igw_route_table.id
}
resource "aws_route_table_association" "to_public_route_c" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.custom_igw_route_table.id
}

# creating elastic-ip for nat gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# creating NAT Gateway and connecting to public subnet 1 for network connection
resource "aws_nat_gateway" "custom_nat" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.public_subnet_1.id
  allocation_id     = aws_eip.nat_eip.id
  depends_on        = [aws_internet_gateway.custom_igw] # Ensure IGW is created before NAT Gateway
}

# creating route table for nat gateway
resource "aws_route_table" "custom_nat_route_table" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = {
    Name = "custom-nat-route-table"
  }
}

# creating route for nat gateway
resource "aws_route" "nat_routs" {
  route_table_id         = aws_route_table.custom_nat_route_table.id
  destination_cidr_block = "0.0.0.0/0" # Route all outbound internet traffic
  nat_gateway_id         = aws_nat_gateway.custom_nat.id
}

# private subnet assosiation to get network connection prom public subnet
resource "aws_route_table_association" "to_private_route_a" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.custom_nat_route_table.id
}
resource "aws_route_table_association" "to_private_route_b" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.custom_nat_route_table.id
}
resource "aws_route_table_association" "to_private_route_c" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.custom_nat_route_table.id
}

# creating security group
resource "aws_security_group" "custom_sg" {
  name   = "custom-sg"
  vpc_id = aws_vpc.custom_vpc.id
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# creating key pair
resource "aws_key_pair" "spain_deployment_key_pair" {
  key_name = "spain-deployment-key"
  public_key = file("~/.ssh/spain-deployment-key.pub")
}

# creating auto launch template
resource "aws_launch_template" "deployment_template" {
  name_prefix   = "deployment-template-"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.spain_deployment_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.custom_sg.id]
  #block_device_mappings {
   # device_name = "/dev/sda1" # Or the appropriate device name for your AMI
    #ebs {
     # volume_size           = var.volume_size
      #delete_on_termination = true
    #}
  #}
}

# creating application load balancer
resource "aws_lb" "deployment_loadbalancer" {
  name               = "deployment-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.custom_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  tags = {
    Name = "deployment-alb"
  }
}

# creating target group
resource "aws_lb_target_group" "target_group" {
  name     = "custom-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

# alb listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.deployment_loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }  
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.deployment_loadbalancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn_elb # Ensure this variable is defined
  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# creating Auto scaling group
resource "aws_autoscaling_group" "deployment_scaling_group" {
  name_prefix        = "deployment-autoscaling-group-"
  max_size           = 2
  min_size           = 1
  desired_capacity = 1
  vpc_zone_identifier = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id,
  ]
  target_group_arns = [aws_lb_target_group.target_group.arn]
  launch_template {
    id      = aws_launch_template.deployment_template.id
    version = "$Latest"
  }
}

# scale out policy
resource "aws_autoscaling_policy" "scaling_up" {
  name                   = "scale-up-policy"
  autoscaling_group_name = aws_autoscaling_group.deployment_scaling_group.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value       = 60.0 # Target CPU utilization percentage
    disable_scale_in = false
  }
}

# creating Database server
resource "aws_instance" "database_instance" {
  ami           = var.database_ami
  instance_type = var.instance_type_db
  key_name      = aws_key_pair.spain_deployment_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.custom_sg.id] # Consider a dedicated SG
  subnet_id     = aws_subnet.private_subnet_1.id # Choose one private subnet

  root_block_device {
    delete_on_termination = false
    volume_size           = var.volume_size_db
  }

  tags = {
    Name = "database-server"
  }
}

# Creating EFS
resource "aws_efs_file_system" "app_file" {
  creation_token = "app-file"
  tags = {
    Name        = "app-file"
    description = "application file persistency"
  }
}

# cretaing CDN Distribution
resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  is_ipv6_enabled = true
  aliases = var.aliases
  price_class = "PriceClass_All"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = "83da9c7e-98b4-4e11-a168-04f0df8e2c65"
    origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    compress               = true
    viewer_protocol_policy = "allow-all"
    target_origin_id       = aws_lb.deployment_loadbalancer.id
  }

  origin {
    domain_name           = aws_lb.deployment_loadbalancer.dns_name
    origin_id             =  aws_lb.deployment_loadbalancer.id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

   viewer_certificate {
     acm_certificate_arn = var.certificate_arn_cdn
     ssl_support_method  = "sni-only"
     minimum_protocol_version = "TLSv1.2_2019"
   }

  restrictions {
    geo_restriction {
      restriction_type = "none" 
      locations        = []
    }
  }
}

