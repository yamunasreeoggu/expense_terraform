resource "aws_iam_role" "main" {
  name               = "${var.env}-${var.project_name}-eks-role"
  assume_role_policy = jsonencode({     #code taken from role creation of app --> main.tf
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"  # as we are creating eks cluster
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.main.name
}

resource "aws_iam_role" "node" {
  name = "${var.env}-${var.project_name}-eks-node-role"

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

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

data "external" "thumbprint" {
  depends_on = [aws_eks_cluster.main]
  program = ["bash","${path.module}/thumbprint.sh", "${var.env}-${var.project_name}"]
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [lookup(data.external.thumbprint.result, "thumbprint", null)]
}

resource "aws_iam_role" "frontend-eks-sa" {
  name = "${var.env}-${var.project_name}-frontend-eks-sa"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::492681564023:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:aud": "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:sub": "system:serviceaccount:default:frontend"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "inline"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt",
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "backend-eks-sa" {
  name = "${var.env}-${var.project_name}-backend-eks-sa"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::492681564023:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:aud": "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:sub": "system:serviceaccount:default:backend"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "inline"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt",
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

resource "aws_iam_role" "schema-eks-sa" {
  name = "${var.env}-${var.project_name}-schema-eks-sa"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::492681564023:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:aud": "sts.amazonaws.com"
            "oidc.eks.us-east-1.amazonaws.com/id/${split("/", aws_eks_cluster.main.identity[0].oidc[0].issuer)[4]}:sub": "system:serviceaccount:default:schema"
          }
        }
      }
    ]
  })

  inline_policy {
    name = "inline"

    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
            "kms:Decrypt",
            "ssm:DescribeParameters",
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}