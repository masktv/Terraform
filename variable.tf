variable "region" {
    description = "select accoreding to location"
    type = string
    default = "ap-southeast-1"
}

variable "vpc_cidr_block" {
    type = string
    default "172.16.0.0/16"
}

variable "pub_sub_cidr_a" {
    type = string
    default "172.16.1.0/24"
}

variable "pub_sub_cidr_b" {
    type = string
    default "172.16.2.0/24"
}

variable "pub_sub_cidr_c" {
    type = string
    default "172.16.3.0/24"
}

variable "priv_sub_cidr_a" {
    type = string
    default "172.16.101.0/24"
}

variable "priv_sub_cidr_b" {
    type = string
    default "172.16.102.0/24"
}

variable "priv_sub_cidr_c" {
    type = string
    default "172.16.103.0/24"
}

# deployment template image_id
variable "image_id" {
    type = string
    default = "ami-065a492fef70f84b1"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "volume_size" {
    type = number
    default = "8"
}

#variable "ssl_certificate_arn" {
 #   type = string 
  #  default = "..."
#}

variable "database_ami" {
    type = string
    default = "ami-065a492fef70f84b1"
}

variable "instance_type_db" {
    type = string
    default = "t2.micro"
}

variable "volume_size_db" {
    type = string
    default = "8"
}


variable "aliases" {
    type    = list(string)
    default = [
        "web.masktvott.com",
        "admin.masktvott.com",
        "masktvott.com"
    ]
}
