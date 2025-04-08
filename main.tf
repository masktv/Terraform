provider "aws" {
    project = "chine"
    region = var.region
}

# creating VPC
resource "aws_vpc" "custom_vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    tag = {
      Name = "custom-vpc" 
    }
}

# creating 3 public subnet for 3 availability_zone
resource "aws_subnet" "public_subnet_1" {
    cidr_block = var.pub_sub_cidr_a
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-1"
    }
}
resource "aws_subnet" "public_subnet_2" {
    cidr_block = var.pub_sub_cidr_b
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-2"
    }
}
resource "aws_subnet" "public_subnet_3" {
    cidr_block = var.pub_sub_cidr_c
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-3"
    }
}

# crerating 3 private subnet for 3 availability_zone
resource "aws_subnet" "private_subnet_1" {
    cidr_block = var.priv_sub_cidr_a
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-1"
    }
}
resource "aws_subnet" "private_subnet_2" {
    cidr_block = var.priv_sub_cidr_b
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-2"
    }
}
resource "aws_subnet" "private_subnet_3" {
    cidr_block = var.priv_sub_cidr_c
    vpc_id = aws_vpc.custom_vpc.id
    availability_zone = ".."
    map_public_ip_on_launch = true
    tag = {
        Name = "az-3"
    }
}

# creating internet gateway
resource "aws_internet_gateway" "custom_igw" {
    vpc_id = aws_vpc.custom_vpc.id
    tags = {
        Name = "custome-igw"
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
resource "aws_route" "igw_routs"{
    route_table_id = aws_route_table.custom_igw_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
}

# subnet assosiation for igw
resource "aws_route_table_association" "to_public_route_a" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.custom_igw_route_table.id
}
resource "aws_route_table_association" "to_public_route_b" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.custom_igw_route_table.id
}
resource "aws_route_table_association" "to_public_route_c" {
    subnet_id = aws_subnet.public_subnet_3.id
    route_table_id = aws_route_table.custom_igw_route_table.id
}

# creating NAT Gateway and connecting to public subnet 1 for network connection
resource "aws_nat_gateway" "custom_nat" {
    connectivity_type = "public"
    subnet_id = aws_subnet.public_subnet_1.id
}

# creating route table for nat gateway
resource "aws_route_table" "custom_nat_route_table" {
    vpc_id = aws_vpc.custom_vpc.id
    tags = {
        Name = "custom-nat-route-table"
    }
}

# creating route for nat gateway
resource "aws_route" "nat_routs"{
    route_table_id = aws_route_table.custom_igw_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.custom_nat.id
}

# private subnet assosiation to get network connection prom public subnet
resource "aws_route_table_association" "to_private_route_a" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.custom_nat_route_table.id
}
resource "aws_route_table_association" "to_private_route_b" {
    subnet_id = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.custom_nat_route_table.id
}
resource "aws_route_table_association" "to_private_route_c" {
    subnet_id = aws_subnet.private_subnet-1.id
    route_table_id = aws_route_table.custom_nat_route_table.id
}

# creating security group
resource "aws_security_group" "custom_sg" {
    name = "custom-sg"
    vpc_id = aws_vpc.custom_vpc.id
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1" # -1 means all protocols
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_block  = ["0.0.0.0/0"]
    }
}

# creating key pair
resource "aws_key_pair" "deployment_key_pair" {
    key_name = "deployment-key"
}

# creating auto launch template
resource "aws_launch_template" "deployment_template" {
    name = "deployment-template"
    image_id = var.image_id
    instance_type = var.instance_type
    key_name = aws_key_pair.deployment_key_pair.key_name
    security_group_id = aws_security_group.custom_sg.id 
    # ebs 
    device_name = "deployment_volume"
    volume_size = var.volume_size
}

# creating application loab balancer
resource "aws_lb" "deployment_loadbalancer" {
    name = "deployment-alb"
    internal = false
    load_balancer_type = "application"
    security_group = [aws_security_group.custom_sg.id]
    subnets = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
    tag = {
        name = "deployment-alb"
    }
}

# creating target group
resource"aws_lb_target_group" "target_group" {
    name = "custom-target-group"
    port = 80
    protoccol = "HTTP"
    vpc_id = aws_vpc.custom_vpc.id
    health_check {
        path = "/"
        interval = 30
        timeout = 5
        healthy_threshold = 3
        unhealthy_threshold = 3
    }
}

# alb listener
resource "aws_lb_listener" "http_listner" {
    load_balancer_arn = aws_lb.deployment_loadbalancer.arn
    port = 80
    protocol  = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.target_group.arn
    }
}
resource aws_lb_listener" "https_listner" {
    load_balancer_arn = aws_lb.deployment_loadbalancer.arn
    port = 443
    protocol  = "HTTPS"
    certificate_arn = var.certificate_arn
    default_action {
        type = "redirect" 
        redirect {
            protocol = "HTTP"
            port = "80"
            status_code = "HTTP_301"
        }
    }
}

# creating Auto scaling group
resource "aws_autoscaling_group" "deployment_scaling_group" {
    name = "deployment-autoscaling-group"
    max_size =  2
    min_size =  1
    desire_capacity = 1
    vpc_zone_identifier  = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
    ]
    target_group_arns = [aws_lb_target_group.target_group.arn]
    launch_template = {
        id = aws_launch_template.deployment_template.id
        version = "$Latest"
    }
}

# scale out policy 
resource "aws_autoscaling_policy" "scaling_up" {
    name                   = "scale-up-policy"
    scaling_adjustment     = 1
    adjustment_type        = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.deployment_scaling_group.name
    policy_type            = "TargetTrackingScaling"
    target_tracking_configuration {
        predefined_metric_specification {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 60.0  # Target CPU utilization percentage
        disable_scale_in = false
    }
}

# scale down policy
resource "aws_autoscaling_policy" "scaling_down" {
    name                    = "scale-down-policy"
    scaling_adjustment      = -1
    adjustment_type         = "ChangeInCapacity"
    autoscaling_group_name = aws_autoscaling_group.deployment_scaling_group.name
    policy_type            = "TargetTrackingScaling"

    target_tracking_configuration {
        predefined_metric_specification {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 30.0  # Scale down when CPU drops below 30%
        disable_scale_in = false
    }
}

# creating Database server 

resource "aws_instance" "database_instance" {
    ami = var.database_ami
    instance_type = var.instance_type_db
    key_name = aws_key_pair.deployment_key_pair.key_name
    security_groups = aws_security_group.custom_sg.id
    subnet_id = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
    ]
    root_block_device = {
        device_name = "database-volume"
        delete_on_termination = false
        volume_size = var.volume_size_db
    }
    tags = {
        Name = "database-server"
    }
}

# Creating EFS 
resource "aws_efs_file_system" "app-file" {
    creation_token = "app-file"
    tag = {
        Name = "app-file"
        description = "application file persistancy"
    }
}

