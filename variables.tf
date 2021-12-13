variable vpc_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "AWS VPC CIDR"
}

variable priv_subnets {
  type        = list(string)
  default     = ["10.0.1.0/16","10.0.2.0/16","10.0.3.0/16"]
  description = "CIDRs for the private subnets"
}

variable pub_subnets {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  description = "CIDRs for the public subnets"
}
