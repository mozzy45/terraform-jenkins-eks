terraform {
  backend "s3" {
    bucket = "cicd-terraform-eks-bucket451"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}
