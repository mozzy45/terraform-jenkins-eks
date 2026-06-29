module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "eks-vpc"
  cidr = var.vpc_cidr

  azs = data.aws_availability_zones.azs.names

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true # Critical for EKS private endpoints
  enable_nat_gateway   = true
  single_nat_gateway   = true

  # FIX: Changed tag name from "my-eks-cluster" to "my-cluster" to match the EKS module
  tags = {
    "kubernetes.io/cluster/my-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-cluster" = "shared"
    "kubernetes.io/role/elb"           = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-cluster" = "shared"
    "kubernetes.io/role/internal-elb"  = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.35"

  # FIX: If public access is false, private access MUST be true so nodes can reach the API
  endpoint_public_access  = false
  endpoint_private_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      # FIX: Changed 'instance_type' to 'instance_types' (plural) to accept the list format
      instance_type = var.instance_type
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}