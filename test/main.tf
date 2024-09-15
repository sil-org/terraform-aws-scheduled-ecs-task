
module "minimal" {
  source = "../"

  ecs_cluster_arn     = "arn:aws:ecs:us-east-1:000000000000:cluster/test-cluster"
  task_definition_arn = "arn:aws:ecs:us-east-1:000000000000:task-definition/test-td:1"
  name                = "test-name"
}

module "full" {
  source = "../"

  ecs_cluster_arn        = "arn:aws:ecs:us-east-1:000000000000:cluster/test-cluster"
  task_definition_arn    = "arn:aws:ecs:us-east-1:000000000000:task-definition/test-td:1"
  name                   = "0123456789abcdef0123456789abcdef0123456789abcdef"
  event_schedule         = "cron(0 0 1 1 ? 1)"
  enable                 = true
  event_rule_description = "a description"
  event_target_input     = jsonencode({ "containerOverrides" : [{ "name" : "container_name", "command" : ["true"] }] })
  tags                   = { tag_name : "tag_value" }
}

output "an_output" {
  value = module.minimal.role_arn
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
