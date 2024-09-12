
locals {
  unique_name = "${var.name}-${random_id.name_suffix.b64_url}"
}

resource "random_id" "name_suffix" {
  byte_length = 6
}

resource "aws_iam_role" "this" {
  name = "ecs_events-${local.unique_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
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
  name = "ecs_events_run_task_with_any_role"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ecs:RunTask"
        Resource = replace(var.task_definition_arn, "/:\\d+$/", ":*")
      },
    ]
  })
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
