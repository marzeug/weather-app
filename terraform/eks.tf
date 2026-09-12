# ── IAM Role pour EKS ──────────────────────────────────────────────────
# EKS a besoin d'un rôle IAM pour gérer les ressources AWS
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Attache les permissions nécessaires au rôle EKS
resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# ── IAM Role pour les noeuds EKS ───────────────────────────────────────
# Les noeuds (machines EC2) ont aussi besoin d'un rôle IAM
resource "aws_iam_role" "node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attache les permissions nécessaires aux noeuds
resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# ── Récupère les subnets disponibles ───────────────────────────────────
# EKS a besoin de subnets pour placer les noeuds
# Récupère uniquement les subnets dans les zones supportées par EKS
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availabilityZone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# ── Cluster EKS ────────────────────────────────────────────────────────
# Le cluster Kubernetes principal
resource "aws_eks_cluster" "main" {
  name     = "demo-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# ── Node Group ─────────────────────────────────────────────────────────
# Les machines EC2 qui font tourner nos conteneurs
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "demo-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = data.aws_subnets.default.ids

  # Type et nombre de machines
  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 1  # nombre de noeuds souhaité
    min_size     = 1  # minimum
    max_size     = 2  # maximum
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
  ]
}

# ── Outputs ────────────────────────────────────────────────────────────
output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}