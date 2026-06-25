
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.azs.names
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
}


# SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security Group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id

  # Changed from [ ] to { } and updated internal argument names
  ingress_rules = {
    jenkins = {
      from_port   = 8080
      to_port     = 8080
      ip_protocol = "tcp"         # Changed 'protocol' to 'ip_protocol'
      description = "HTTP"
      cidr_ipv4   = "0.0.0.0/0"   # Changed 'cidr_blocks' to 'cidr_ipv4'
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"         # Changed 'protocol' to 'ip_protocol'
      description = "SSH"
      cidr_ipv4   = "0.0.0.0/0"   # Changed 'cidr_blocks' to 'cidr_ipv4'
    }
  }

  # Changed from [ ] to { } and updated internal argument names
  egress_rules = {
    all_traffic = {
      ip_protocol = "-1"          # Changed 'protocol' to 'ip_protocol'
      cidr_ipv4   = "0.0.0.0/0"   # Changed 'cidr_blocks' to 'cidr_ipv4'
    }
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  instance_type               = var.instance_type
  key_name                    = "jenkins-server-key"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.id] # Fixed: Changed security_group_id to id
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]

  tags = {
    Name        = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}