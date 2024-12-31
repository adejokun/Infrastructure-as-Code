#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}


data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.k8-dir-app.name
}

data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.k8-dir-app.name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name",aws_eks_cluster.k8-dir-app.name]
      command     = "aws"
    }
  }
}
