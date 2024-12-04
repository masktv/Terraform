provider "aws" {
  access_key = var.access-key
  secret_key = var.secret-key
  region = "ap-south-1"
}
resource "aws_vpc" "masktv-deployment" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true
}
resource "aws_subnet" "public-subnet" {
  availability_zone = ""
  cidr_block = ""
  map_public_ip_on_launch = "true"
  vpc_id = aws_vpc.masktv-deployment.id
  tags = {
    env = production
    type = public
  }
}
resource "aws_subnet" "private-subnet" {
  availability_zone = ""
  cidr_block = ""
  map_public_ip_on_launch = "false"
  vpc_id = aws_vpc.masktv-deployment.id
  tags = {
    env = production
    type = private
  }
}
resource "aws_internet_gateway" "masktv-igw" {
  vpc_id = aws_vpc.masktv-deployment.id
}
resource "aws_route_table" "masktv-deployment-rt" {
  vpc_id = aws_vpc.masktv-deployment.id
  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.masktv-igw.id
  }
}
resource "aws_route_table_association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.masktv-deployment-rt.id
}
resource "aws_launch_template" "deployment-template" {
  disable_api_stop = true
  disable_api_termination = true
  image_id = var.image-id
  instance_type = "value"
  name = "deployment-template"
}
resource "aws_autoscaling_group" "deployment-autoscaling-grp" {
  name = "masktv-autoscale-grp"
  max_size = "2"
  min_size = "1"
  desired_capacity = "1"
  launch_ttemplate = {
    id = aws_launch_template.deployment-template.id
  } 
}
resource "aws_lb_target_group" "masktv-tg" {
  name = "value"
  port = "80"
  protocol = "TCP"
  vpc_id = aws_vpc.masktv-deployment.id
}
resource "aws_lb" "deployment-loadbalancer" {
  enable_deletion_protection = ""
  load_balancer_type = "application"
  name = "deployment-lb"
}
resource "aws_lb_listener" "https-listner" {
  load_balancer_arn = aws_lb.deployment-loadbalancer.arn
  port = "443"
  protocol = "HTTPS"
  default_action = {
    type = "forward" 
    target_group = aws_lb_target_group.masktg.arn
  }
}
resource "aws_lb_listener" "http-listner" {
  load_balancer_arn = aws_lb.deployment-loadbalancer.arn
  port = "80"
  default_action = {
    type = "redirect"
    redirect {
      protocol = "HTTPS" 
      port     = "443"  
    }
  }
}
resource "aws_lb_listener_certificate" "ssl" {
  listener_arn    = aws_lb_listener.https-listner.arn
  certificate_arn = "value"
}

resource "aws_cloudfront_distribution" "cdn" {
  default_cache_behavior = {
    allowed_methos = 
    caced_methods = 
  }
  origin = {
    domain_name = bucket
    origin_id = 
  }
  viewer_certificate = 
  restrictions = 
}
