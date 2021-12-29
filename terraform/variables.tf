variable region {
  type        = string
  default     = "us-east-1"
  description = "AWS Region for resource"
}

variable projectName {
  type        = string
  description = "Name of the project. This name will be appended to all resources created"
}

variable domainName {
  type        = string
  description = "Domain name for DNS entry"
}

variable subDomain {
  type        = string
  description = "Subdomain for DNS entry"
}


variable vpcCidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for the VPC for the project"
}

variable awsAzs {
  type        = list(string)
  description = "List of AWS availability zones to create subnets into"
}

variable privateSubnets {
  type        = list(string)
  description = "List of AWS private subnets"
}

variable publicSubnets {
  type        = list(string)
  description = "List of AWS public subnets"
}

variable rancherOsAMI {
  type        = string
  description = "Enter the AMI of the RancherOS image"
}

variable allowedIngressCidr {
  type        = list(string)
  description = "CIDR block of allowed IPs to ingress to Rancher (0.0.0.0/0 for all)"
}

variable nodeCount {
  type        = string
  description = "Number of Rancher nodes"
}

variable rancherAmi {
  type        = string
  description = "AMI value for the RancherOS"
}

variable instanceType {
  type        = string
  description = "AWS EC2 instance type"
}







