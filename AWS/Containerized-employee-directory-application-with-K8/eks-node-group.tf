## IAM Role - Node Group
resource "aws_iam_role" "k8-node-group" {
  name = "k8-t-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8-node-group.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8-node-group.name
}

## EKS Node Group
resource "aws_eks_node_group" "k8-node-group" {
  cluster_name    = aws_eks_cluster.k8-dir-app.name
  node_group_name = "k8-t-node-group"
  node_role_arn   = aws_iam_role.k8-node-group.arn
  subnet_ids      = [
    aws_subnet.private-01.id,
    aws_subnet.private-02.id
    ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  ami_type = "AL2_x86_64"
  instance_types = ["t3.medium"]
  disk_size = "20"
  capacity_type = "ON_DEMAND"
  
  remote_access {
    ec2_ssh_key = "employee-dir-app-key" # provide EC2 key pair name
    source_security_group_ids = [aws_security_group.node-grp.id]
  }
 
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}