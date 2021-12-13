################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  node_groups = {
    # create launch template
    example2 = {
      create_launch_template = true
      desired_capacity       = var.lt_ng_desired_capacity
      max_capacity           = var.lt_ng_max_capacity
      min_capacity           = var.lt_ng_min_capacity

      disk_size       = var.lt_ng_disk_size
      disk_type       = var.lt_ng_disk_type
      disk_throughput = 150
      disk_iops       = 3000

      instance_types = var.lt_ng_instance_type
      capacity_type  = "ON_DEMAND"

      bootstrap_env = {
        CONTAINER_RUNTIME = "docker"
        USE_MAX_PODS      = false
      }
      kubelet_extra_args = "--max-pods=110"
      k8s_labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  tags = {
    Cluster_Name    = local.cluster_name
  }
}

################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

################################################################################
# Supporting Resources
################################################################################

resource "random_string" "suffix" {
  length  = 8
  special = false
}
