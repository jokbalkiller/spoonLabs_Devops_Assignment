terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.89.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.4"
    }
  }
  required_version = ">= 1.5.7"

  # backend "s3" {
  #   bucket         = "tfstate"
  #   region         = "ap-northeast-2"
  #   key            = ""
  #   access_key     = ""
  #   secret_key     = ""
  #   encrypt        = true
  #   dynamodb_table = "terraformtfstateLock"
  # }
}

provider "aws" {
  access_key = "mock_access_key"
  region     = "ap-northeast-2"
  secret_key = "mock_secret_key"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

