variable "region" {
  description = "select accoreding to location"
  type        = string
  default     = "ap-southeast-1"
}

variable "remote_backend_bucket" {
  type    =  string
  default = "spain-infra.tfstate"
}

variable "key" {
default = "terraform-backend/terraform.tfstate"
}

variable "vpc_cidr_block" {
  type    = string
  default = "172.16.0.0/16"
}

variable "pub_sub_cidr_a" {
  type    = string
  default = "172.16.1.0/24"
}

variable "pub_sub_cidr_b" {
  type    = string
  default = "172.16.2.0/24"
}

variable "pub_sub_cidr_c" {
  type    = string
  default = "172.16.3.0/24"
}

variable "priv_sub_cidr_a" {
  type    = string
  default = "172.16.101.0/24"
}

variable "priv_sub_cidr_b" {
  type    = string
  default = "172.16.102.0/24"
}

variable "priv_sub_cidr_c" {
  type    = string
  default = "172.16.103.0/24"
}

# deployment template image_id
variable "image_id" {
  type    = string
  default = "ami-0f458abd9c6cc8249"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "volume_size" {
  type    = number
  default = 8
}

variable "certificate_arn_elb" {
  type    = string
  default = "arn:aws:acm:ap-southeast-1:232168115105:certificate/a4f5b0eb-5ef0-42e7-8e28-77976bbbd4a1" # Replace with your actual certificate ARN
}

variable "certificate_arn_cdn" {
  type    = string
  default = "arn:aws:acm:us-east-1:232168115105:certificate/35ed7849-08cb-4586-b933-cf071ee999de" # Replace with your actual certificate ARN
}

variable "database_ami" {
  type    = string
  default = "ami-0316c6c42b1288dcb"
}

variable "instance_type_db" {
  type    = string
  default = "t2.micro"
}

variable "volume_size_db" {
  type    = string
  default = "8"
}

variable "aliases" {
  type    = list(string)
  default = [
    "web.makerzmedia.com",
    "admin.makerzmedia.com",
    "makerzmedia.com",
  ]
}
