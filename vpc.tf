################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"  

  name = local.app_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.priv_subnets
  public_subnets  = var.pub_subnets

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = true
}

################################################################################
# Supporting Resources
################################################################################

data "aws_availability_zones" "available" {
  state = "available"
}