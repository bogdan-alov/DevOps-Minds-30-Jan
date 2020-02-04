### Set the providers
provider "aws" {
  version                 = "= 2.46.0"
  region                  = "eu-central-1"
  shared_credentials_file = "~/.aws"
  profile                 = "DEVOPS_MINDS"
}

data "aws_availability_zones" "available" {}


#### VPC Setup ###

resource "aws_vpc" "devops-minds" {
  cidr_block = "172.16.0.0/16"

  tags = map(
    "Name", "eks-devops-minds-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "devops-minds" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "172.16.${count.index}.0/24"
  vpc_id            = aws_vpc.devops-minds.id

  tags = map(
    "Name", "eks-devops-minds-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "devops-minds" {
  vpc_id = aws_vpc.devops-minds.id

  tags = {
    Name = "terraform-eks-devops-minds"
  }
}

resource "aws_route_table" "devops-minds" {
  vpc_id = aws_vpc.devops-minds.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-minds.id
  }
}

resource "aws_route_table_association" "devops-minds" {
  count = 2

  subnet_id      = aws_subnet.devops-minds.*.id[count.index]
  route_table_id = aws_route_table.devops-minds.id
}



###EKS cluster setup 

resource "aws_iam_role" "devops-minds-cluster" {
  name = "terraform-eks-devops-minds-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "devops-minds-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.devops-minds-cluster.name
}

resource "aws_iam_role_policy_attachment" "devops-minds-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.devops-minds-cluster.name
}

resource "aws_security_group" "devops-minds-cluster" {
  name        = "terraform-eks-devops-minds-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.devops-minds.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-devops-minds"
  }
}

locals {
  external-cidr = "195.24.36.64/29"
}

resource "aws_security_group_rule" "devops-minds-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.devops-minds-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "devops-minds" {
  name     = var.cluster-name
  role_arn = aws_iam_role.devops-minds-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.devops-minds-cluster.id]
    subnet_ids         = aws_subnet.devops-minds[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.devops-minds-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.devops-minds-cluster-AmazonEKSServicePolicy,
  ]
}

### EKS nodes setup

resource "aws_iam_role" "devops-minds-node" {
  name = "terraform-eks-devops-minds-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "devops-minds-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.devops-minds-node.name
}

resource "aws_iam_role_policy_attachment" "devops-minds-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.devops-minds-node.name
}

resource "aws_iam_role_policy_attachment" "devops-minds-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.devops-minds-node.name
}

resource "aws_eks_node_group" "devops-minds" {
  cluster_name    = aws_eks_cluster.devops-minds.name
  node_group_name = "devops-minds"
  node_role_arn   = aws_iam_role.devops-minds-node.arn
  subnet_ids      = aws_subnet.devops-minds[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.devops-minds-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.devops-minds-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.devops-minds-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# Prepare ECR repository

resource "aws_ecr_repository" "devops-minds-repository" {
  name                 = "python-demo-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


