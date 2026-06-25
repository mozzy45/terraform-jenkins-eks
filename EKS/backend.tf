terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-bucket451"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}