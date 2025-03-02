resource "aws_eip" "nat" {
  count = 1
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${terraform.workspace}-vpc"
  cidr = "10.21.0.0/16"
  external_nat_ip_ids = aws_eip.nat.*.id

  azs             = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.21.32.0/24", "10.21.33.0/24"]
  public_subnets  = ["10.21.0.0/24", "10.21.1.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = var.cluster_name
  }

  tags = {
    Terraform = "true"
    Environment = terraform.workspace
  }
}