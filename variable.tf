variable "region" {
    description = "select accoreding to location"
    type = string
    default = "ap-south-1"
}

variable "vpc_cidr_block" {
    type = string
    default "....."
}

variable "pub_sub_cidr_a" {
    type = string
    default "....."
}

variable "pub_sub_cidr_b" {
    type = string
    default "....."
}

variable "pub_sub_cidr_c" {
    type = string
    default "....."
}

variable "priv_sub_cidr_a" {
    type = string
    default "....."
}

variable "priv_sub_cidr_a" {
    type = string
    default "....."
}

variable "priv_sub_cidr_c" {
    type = string
    default "....."
}

# deployment template image_id
variable "image_id" {
    type = string
    default = "...."
}

variable "instance_type" {
    type = string
    default = "...."
}

variabe "volume_size" {
    type = number
    default = "....."
}

variable "ssl_certificate_arn" {
    type = string 
    default = "..."
}

variable "database_ami" {
    type = string
    default = "...."
}

variable "instance_type_db" {
    type = string
    default = "...."
}

variable "volume_size_db" {
    type = string
    default = "...."
}


variable "aliases" {
    type = string
    default = "...."
}
