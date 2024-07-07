terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      ManagedBy = "Terraform"

    }
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "public_default" {
  route_table_id         = aws_vpc.this.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = "eu-west-1${element(["a", "b", "c"], count.index)}"
}

module "this" {
  source  = "../../"
  name    = "ssm-bastion"
  vpc_id  = aws_vpc.this.id
  subnets = aws_subnet.public[*].id
  assign_public_ip = true

  depends_on = [ aws_route.public_default ]
}