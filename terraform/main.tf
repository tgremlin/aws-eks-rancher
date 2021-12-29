terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# this will be the ranchoer os AMI ami-02fe87f853d560d52

resource "aws_security_group" "rancher-elb" {
  name   = "${var.projectName}-rancher-elb"
  vpc_id = module.vpc.vpc_id
  # Security group rules to expose rancher ports
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowedIngressCidr
  }
}

resource "aws_security_group" "rancher" {
  name   = "${var.projectName}-rancher-server"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = ["${aws_security_group.rancher-elb.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "TCP"
    security_groups = ["${aws_security_group.rancher-elb.id}"]
  }

  # K8s kube-api for kubectl
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  # K8s NodePorts
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "TCP"
    cidr_blocks = var.allowedIngressCidr
  }

  # Open intra-cluster
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "rancher" {
  count         = var.nodeCount
  ami           = var.rancherAmi
  instance_type = var.instanceType
  key_name      = "${aws_key_pair.sshKey.id}"
  user_data     = "${data.template_file.cloud_config.rendered}"

  vpc_security_group_ids      = ["${aws_security_group.rancher.id}"]
  subnet_id                   = [module.vpc.private_subnets]
  associate_public_ip_address = false

  #  iam_instance_profile = "k8s-ec2-route53"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "50"
  }
  tags = {
    Name = "${var.projectName}-${count.index}"
    Terraform = "true"
    Environment = var.environment
    Project Name = var.projectName    
  }
}

resource "aws_elb" "rancher" {
  name            = "${var.projectName}-elb"
  subnets         = [module.vpc.public_subnets]
  security_groups = ["${aws_security_group.rancher-elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "tcp:80"
    interval            = 5
  }

  instances    = ["${aws_instance.rancher.*.id}"]
  idle_timeout = 1800

  tags {
    Name = "${var.projectName}"
  }
}

#######################################################################
## Supporting resources
#######################################################################

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yaml")}"
}

# Create SSH key pair for admin of server
resource "aws_key_pair" "sshKey" {
    key_name = "${var.projectName}-ssh"
    # This will be passed using an environment variable in the CI/CD pipeline
    public_key = var.publicKey
}


#######################################################################
## VPC
#######################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.projectName}-${var.region}-vpc"
  cidr = var.vpcCidr

  azs             = var.awsAzs
  private_subnets = var.privateSubnets
  public_subnets  = var.publicSubnets

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = var.environment
    Project Name = var.projectName
  }
}

#######################################################################
## DNS
#######################################################################

# Hosted Zone for apex domain
resource "aws_route53_zone" "zoneApex" {
  name          = var.domainName
  comment       = "Hosted Zone for ${var.domainName}"

  tags {
    Name      = var.domainName
    Terraform = "true"
    Environment = var.environment
    Project Name = var.projectName
  }
}

# Hosted Zone for subdomain
resource "aws_route53_zone" "subDomain" {
  name          = var.subDomain
  comment       = "Hosted Zone for ${var.subDomain}-${var.domainName}"

  tags {
    Name      = "${var.subDomain}.${var.domainName}"
    Terraform = "true"
    Environment = var.environment
    Project Name = var.projectName
  }
}

# DNS
resource "aws_route53_record" "rancher" {
  zone_id = aws_route53_zone.subDomain.id
  name    = "${var.server_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.rancher.dns_name}"
    zone_id                = "${aws_elb.rancher.zone_id}"
    evaluate_target_health = true
  }
}


