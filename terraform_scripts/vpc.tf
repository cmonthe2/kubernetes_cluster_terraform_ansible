provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "kubernetes" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "kubernetes"
  }
}
resource "aws_internet_gateway" "kubernetes_vpc_igw" {
  vpc_id = aws_vpc.kubernetes.vpc_id
tags = {
Name = "kubernetes_vpc_igw"
}
}

resource "aws_subnet" "kubernetes_subnets" {
count                    = length(var.subnets_cidr)
vpc_id                   = aws_vpc.kubernetes.vpc_id
cidr_block               = element(var.subnets_cidr, count.index)
availability_zone        = element(var.availability_zones, count.index)
map_public_ip_on_launch  = true
tags = {
Name = "kubernetes_subnets_${count.index + 1}"
}
}

resource "aws_route_table" "kubernetes_public_rt" {
vpc_id = aws_vpc.kubernetes.vpc_id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.kubernetes_vpc_igw.id
}
tags = {
Name = "kubernetes_vpc_public_rt"
}
}


resource "aws_route_table-association" "rt_sub_assocaition" {
count   = length(var.subnets_cidr)
subnet_id  = element(aws_subnet.kubernetes_subnets.*.id, count.index)
route_table_id = aws_route_table.kubernetes_public_rt.id
}





}