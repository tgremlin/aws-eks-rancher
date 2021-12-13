locals {
  region = "us-east-1"
  app_name = "aws-eks-rancher"
  cluster_name  = "lt_with_mng-${random_string.suffix.result}"
  cluster_version = "1.20"
}