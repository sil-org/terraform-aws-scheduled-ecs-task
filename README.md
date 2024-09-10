# Terraform module for ...

This module manages an ECS task scheduled by EventBridge 

This module is published in [Terraform Registry](https://registry.terraform.io/modules/silinternational/scheduled-ecs-task/aws/latest).

## Usage Example

```hcl
module "this" {
  source = "silinternational/scheduled-ecs-task/aws"
  version = "0.1.0"

  name                   = "${var.app_name}-cron-${var.app_env}-${local.aws_region}"
  event_rule_description = "Start scheduled tasks"
  event_schedule         = "cron(0 0 * * ? *)"
  ecs_cluster_arn        = var.ecs_cluster_id
  task_definition_arn    = module.ecsservice.task_def_arn
  event_target_input = jsonencode({
    containerOverrides = [
      {
        name   = "web"
        cpu    = var.cpu_cron
        memory = var.memory_cron
        command = ["task-runner"]
        environment = [
          {
            "name" : "TASK_PARAMS",
            "value" : "${var.task_params}"
          }
        ]
      }
    ]
  })
  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

provider "aws" {
  region = "us-east-1"
}
```
