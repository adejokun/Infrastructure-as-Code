## IAM Role - EKS Cluster

resource "aws_iam_role" "k8-cluster" {
  name = "k8-t-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8-cluster.name
}

## Access Entry
# create access entry
resource "aws_eks_access_entry" "k8-cluster" {
  cluster_name      = aws_eks_cluster.k8-dir-app.name
  principal_arn     = "arn:aws:iam::992382381749:user/Adedamola"
  type              = "STANDARD"
}

# create access entry association
resource "aws_eks_access_policy_association" "k8-cluster" {
  cluster_name  = aws_eks_cluster.k8-dir-app.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::992382381749:user/Adedamola"

  access_scope {
    type       = "cluster"
  }
}


## EKS Cluster
resource "aws_eks_cluster" "k8-dir-app" {
  name = "k8-t-dir-app"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.k8-cluster.arn
  version  = "1.31"

  vpc_config {
    endpoint_private_access = "true"
    endpoint_public_access  = "true"
    public_access_cidrs     = ["0.0.0.0/0"] # restrict block for production workloads

    subnet_ids = [
      aws_subnet.public-01.id,
      aws_subnet.public-02.id,
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]


}


## Add-ons
resource "aws_eks_addon" "vpc-cni" {
  cluster_name  = aws_eks_cluster.k8-dir-app.name
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
  cluster_name = aws_eks_cluster.k8-dir-app.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.k8-dir-app.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "node-monitoring-agent" {
  cluster_name = aws_eks_cluster.k8-dir-app.name
  addon_name   = "eks-node-monitoring-agent"
}

resource "aws_eks_addon" "example" {
  cluster_name                = "k8-t-dir-app"
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



