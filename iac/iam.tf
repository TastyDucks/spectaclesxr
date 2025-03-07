resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:tastyducks/spectaclesxr:ref:refs/heads/master"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_and_ecs_deploy" {
  depends_on  = [aws_ecs_service.spectaclesxr_service]
  name        = "ecr-and-ecs-deploy-policy"
  description = "Policy to allow pushing to ECR and update ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permissions to push to ECR.
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = aws_ecr_repository.spectaclesxr.arn
      },
      # Permissions to force a new deployment.
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:ListServices",
          "ecs:ListTasks",
          "ecs:WaitForServicesStable",
        ]
        Resource = aws_ecs_service.spectaclesxr_service.id
      },
      # Permissions to assume identity via OIDC.
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRoleWithWebIdentity"
        Resource = aws_iam_role.github_actions.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_and_ecs_deploy.arn
}

resource "aws_iam_role" "ecs_run" {
  name = "ecs-run"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_run" {
  name        = "ecs-run-policy"
  description = "Policy to allow running ECS tasks"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_run_policy" {
  role       = aws_iam_role.ecs_run.name
  policy_arn = aws_iam_policy.ecs_run.arn
}
