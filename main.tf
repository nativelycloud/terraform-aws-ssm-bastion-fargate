resource "aws_iam_role" "task" {
  name = "${var.name}-task-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_ecs" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_ecs_exec" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "task_ecs_exec" {
  name   = "ecs-exec"
  role   = aws_iam_role.task.name
  policy = data.aws_iam_policy_document.task_ecs_exec.json
}

resource "aws_ecs_cluster" "this" {
  name = var.name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.name
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = jsonencode([{
    "name"      = "ssm"
    "image"     = "public.ecr.aws/amazonlinux/amazonlinux:2023-minimal"
    "essential" = true
    "command"   = ["bash", "-c", "while true; do sleep infinity; done"]
    "linuxParameters" = {
      "initProcessEnabled" = true
    }
  }])

  task_role_arn = aws_iam_role.task.arn
}

resource "aws_security_group" "this" {
  count       = var.create_default_security_group ? 1 : 0
  name        = var.name
  vpc_id      = var.vpc_id
  description = "Allow all outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "this" {
  name                   = var.name
  cluster                = aws_ecs_cluster.this.arn
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = var.subnets
    security_groups  = concat(var.security_groups, aws_security_group.this[*].id)
    assign_public_ip = var.assign_public_ip
  }

  depends_on = [aws_iam_role_policy_attachment.task_ecs]
}