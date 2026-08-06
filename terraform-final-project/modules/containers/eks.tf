data "aws_iam_policy_document" "eks_cluster_assume_role" {
  count = var.enable_eks_cluster ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  count = var.enable_eks_cluster ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  count = var.enable_eks_cluster ? 1 : 0

  name               = "${var.name_prefix}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role[0].json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-eks-cluster-role" })
}

resource "aws_iam_role_policy_attachment" "eks_cluster" {
  count = var.enable_eks_cluster ? 1 : 0

  role       = aws_iam_role.eks_cluster[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "eks_node" {
  count = var.enable_eks_cluster ? 1 : 0

  name               = "${var.name_prefix}-eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role[0].json
  tags               = merge(var.tags, { Name = "${var.name_prefix}-eks-node-role" })
}

resource "aws_iam_role_policy_attachment" "eks_node_worker" {
  count = var.enable_eks_cluster ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_cni" {
  count = var.enable_eks_cluster ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_registry" {
  count = var.enable_eks_cluster ? 1 : 0

  role       = aws_iam_role.eks_node[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_cloudwatch_log_group" "eks" {
  count = var.enable_eks_cluster ? 1 : 0

  name              = "/aws/eks/${var.name_prefix}/cluster"
  retention_in_days = 14
  kms_key_id        = var.kms_key_arn
  tags              = merge(var.tags, { Name = "${var.name_prefix}-eks-logs" })
}

resource "aws_eks_cluster" "app" {
  count = var.enable_eks_cluster ? 1 : 0

  name     = "${var.name_prefix}-eks"
  role_arn = aws_iam_role.eks_cluster[0].arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster,
    aws_cloudwatch_log_group.eks
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-eks" })
}

resource "aws_eks_node_group" "default" {
  count = var.enable_eks_cluster ? 1 : 0

  cluster_name    = aws_eks_cluster.app[0].name
  node_group_name = "${var.name_prefix}-default"
  node_role_arn   = aws_iam_role.eks_node[0].arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.small"]
  capacity_type   = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_worker,
    aws_iam_role_policy_attachment.eks_node_cni,
    aws_iam_role_policy_attachment.eks_node_registry
  ]

  tags = merge(var.tags, { Name = "${var.name_prefix}-eks-default" })
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.enable_eks_cluster ? 1 : 0

  cluster_name = aws_eks_cluster.app[0].name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.default]
}
