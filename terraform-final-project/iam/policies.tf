data "aws_iam_policy_document" "ec2_runtime" {
  statement {
    sid = "ReadOwnInstanceMetadataSupportingServices"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = ["*"]
  }

  statement {
    sid = "WriteApplicationLogs"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_runtime" {
  name        = "${var.name_prefix}-ec2-runtime"
  description = "Least-privilege runtime policy for capstone EC2 instances."
  policy      = data.aws_iam_policy_document.ec2_runtime.json
  tags        = merge(var.tags, { Name = "${var.name_prefix}-ec2-runtime" })
}

resource "aws_iam_role_policy_attachment" "ec2_runtime" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_runtime.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task" {
  statement {
    sid       = "ReadApplicationConfiguration"
    actions   = ["ssm:GetParameter", "secretsmanager:GetSecretValue", "kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task" {
  name        = "${var.name_prefix}-ecs-task"
  description = "Runtime policy for ECS application tasks."
  policy      = data.aws_iam_policy_document.ecs_task.json
  tags        = merge(var.tags, { Name = "${var.name_prefix}-ecs-task" })
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}
