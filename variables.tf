variable vpc_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "AWS VPC CIDR"
}

variable priv_subnets {
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  description = "CIDRs for the private subnets"
}

variable pub_subnets {
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  description = "CIDRs for the public subnets"
}

variable lt_ng_desired_capacity {
  type        = string
  default     = 3
  description = "Desired number of instances in EKS Nodegroup launch template"
}

variable lt_ng_max_capacity {
  type        = string
  default     = 10
  description = "Max number of instances in EKS Nodegroup launch template"
}

variable lt_ng_min_capacity {
  type        = string
  default     = 3
  description = "Minimum number of instances in EKS Nodegroup launch template"
}

variable lt_ng_disk_size {
  type        = string
  default     = 20
  description = "EKS Nodegroup instance disk size"
}

variable lt_ng_disk_type {
  type        = string
  default     = "gp3"
  description = "EKS Nodegroup instance disk type"
}

variable lt_ng_instance_type {
  type        = list(string)
  default     = ["t3.micro"]
  description = "EC2 Instance type for EKS Nodegroup"
}





