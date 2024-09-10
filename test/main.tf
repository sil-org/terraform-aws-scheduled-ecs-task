
module "minimal" {
  source = "../"

  ecs_cluster_arn     = ""
  task_definition_arn = ""
  name                = ""
}

module "full" {
  source = "../"

  ecs_cluster_arn        = "a"
  task_definition_arn    = "b"
  name                   = "c"
  event_schedule         = "d"
  enable                 = true
  event_rule_description = "e"
  event_target_input     = "f"
  tags                   = { g : "h" }
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
