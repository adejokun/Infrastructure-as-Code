## Create Cluster, Managed Node Group, and associated resources
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "k8-dir-app"
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  cluster_endpoint_private_access          = true 
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"]
  enable_irsa                              = true
  vpc_id                                   = aws_vpc.k8-t-vpc.id
  subnet_ids                               = [aws_subnet.private-01.id, aws_subnet.private-02.id] 
  control_plane_subnet_ids                 = [aws_subnet.public-01.id, aws_subnet.public-02.id]
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    eks_nodegroup_1 = {
      ami_type       = "AL2_x86_64"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}


# Attach policy to Managed Node Group IAM Role to enable access to Amazon S3
resource "aws_iam_role_policy_attachment" "ecs-S3" {
  role       = module.eks.eks_managed_node_groups.eks_nodegroup_1.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


# Attach policy to Managed Node Group IAM Role to enable access to Amazon DynamoDB
resource "aws_iam_role_policy_attachment" "ecs-DynamoDB" {
  role       = module.eks.eks_managed_node_groups.eks_nodegroup_1.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}



## Add-ons
resource "aws_eks_addon" "vpc-cni" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.5-eksbuild.1"
  configuration_values = jsonencode(
    {
      env = {

        ENABLE_PREFIX_DELEGATION          = "true" # Required for ALB to work with target type ip
        WARM_ENI_TARGET                   = "1"    # optional prefix IP pool.
        WARM_PREFIX_TARGET                = "1"
        POD_SECURITY_GROUP_ENFORCING_MODE = "standard"
        AWS_VPC_K8S_CNI_EXTERNALSNAT      = "true" # Optional when using SG for pod outbound traffic routing.
        ENABLE_POD_ENI                    = "true" # If using Security group for pods

      }
      enableNetworkPolicy = "true"
    }
  )
}

resource "aws_eks_addon" "pod-identity-agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "node-monitoring-agent" {
  cluster_name = module.eks.cluster_name
  addon_name   = "eks-node-monitoring-agent"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    replicaCount = 4
    resources = {
      limits = {
        cpu    = "100m"
        memory = "150Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "150Mi"
      }
    }
  })
}





