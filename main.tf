
locals {
  unique_name = "${var.name}-${random_id.name_suffix.b64_url}"
  pass_role_resources = compact([
    data.aws_ecs_task_definition.this.task_role_arn,
    data.aws_ecs_task_definition.this.execution_role_arn,
  ])
}

data "aws_ecs_task_definition" "this" {
  task_definition = var.task_definition_arn
}

resource "random_id" "name_suffix" {
  byte_length = 6
}

resource "aws_iam_role" "this" {
  name = "events-${local.unique_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "run_task"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["${data.aws_ecs_task_definition.this.arn_without_revision}:*"]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [var.ecs_cluster_arn]
    }
  }

  dynamic "statement" {
    for_each = length(local.pass_role_resources) > 0 ? [1] : []

    content {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = local.pass_role_resources

      condition {
        test     = "StringEquals"
        variable = "iam:PassedToService"
        values   = ["ecs-tasks.amazonaws.com"]
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = local.unique_name
  description         = var.event_rule_description == "" ? "Start ${var.name} task" : var.event_rule_description
  schedule_expression = var.event_schedule
  state               = var.enable ? "ENABLED" : "DISABLED"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  target_id = local.unique_name
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = var.ecs_cluster_arn
  role_arn  = aws_iam_role.this.arn
  input     = var.event_target_input

  ecs_target {
    task_count          = 1
    launch_type         = "EC2"
    task_definition_arn = var.task_definition_arn
    propagate_tags      = "TASK_DEFINITION"
  }
}
