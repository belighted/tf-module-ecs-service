### non-efs task ###
resource "aws_ecs_task_definition" "task" {
  count = tobool(var.efs_variable["enable"]) ? 0 : 1

  family = var.service_name

  container_definitions = var.template

  # check task definition parameters compatibilies
  requires_compatibilities = [var.ecs_launch_type]

  cpu          = var.cpu
  memory       = var.memory
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  task_role_arn = var.ecs_task_iam_role_arn
}

### non-efs services ###
resource "aws_ecs_service" "service_lb_fargate" {
  # service with LB and Fargate
  count = var.scheduled_job ? 0 : true && var.load_balancer_enabled ? 1 : 0 && tobool(var.efs_variable["enable"]) ? 0 : 1

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = var.ecs_launch_type
  platform_version = var.ecs_fargate_platform_version

  #task_definition                   = aws_ecs_task_definition.task.arn
  task_definition                    = var.service_name
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnets_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.service_lb_fargate.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fargate_service.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group[0].arn
    container_name   = var.container_name != "" ? var.container_name : var.service_name

    // container_port   = var.service_port
    container_port = lookup(var.service_ports, var.service_name)
  }

  depends_on = [
    aws_ecs_task_definition.task,
    aws_alb_target_group.target_group,
    aws_alb_listener_rule.https,
    aws_iam_role_policy.ecs_autoscale_role_policy
  ]
}

resource "aws_ecs_service" "service_fargate" {
  # service without LB and with Fargate
  count = var.scheduled_job ? 0 : true && var.load_balancer_enabled ? 0 : 1 && tobool(var.efs_variable["enable"]) ? 0 : 1

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = var.ecs_launch_type
  platform_version = var.ecs_fargate_platform_version

  #task_definition                    = aws_ecs_task_definition.task.arn
  task_definition                    = var.service_name
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnets_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.service_lb_fargate.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fargate_service.arn
  }

  depends_on = [
    aws_ecs_task_definition.task,
    aws_iam_role_policy.ecs_autoscale_role_policy
  ]
}

### efs task ###
resource "aws_ecs_task_definition" "task_efs" {
  count = tobool(var.efs_variable["enable"]) ? 1 : 0 && var.scheduled_job ? 0 : 1

  family = var.service_name

  container_definitions = var.template

  # attaching an efs to the container
  volume {
    name = var.efs_variable["name"]
    efs_volume_configuration {
      file_system_id = var.efs_variable["file_system_id"]
      root_directory = var.efs_variable["file_root_directory"]
    }
  }

  # check task definition parameters compatibilies
  requires_compatibilities = [var.ecs_launch_type]

  cpu          = var.cpu
  memory       = var.memory
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  task_role_arn = var.ecs_task_iam_role_arn

  tags = {
    Name = var.service_name
    Env  = var.environment
  }
}

### efs services ###
resource "aws_ecs_service" "service_efs_lb_fargate" {
  # service with LB and Fargate
  count = var.scheduled_job ? 0 : true && var.load_balancer_enabled ? 1 : 0 && var.scheduled_job ? 0 : 1 && tobool(var.efs_variable["enable"]) ? 1 : 0

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = var.ecs_launch_type
  platform_version = var.ecs_fargate_platform_version

  #task_definition                   = aws_ecs_task_definition.task.arn
  task_definition                    = var.service_name
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnets_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.service_lb_fargate.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fargate_service.arn
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group[0].arn
    container_name   = var.container_name != "" ? var.container_name : var.service_name

    // container_port   = var.service_port
    container_port = lookup(var.service_ports, var.service_name)
  }

  depends_on = [
    aws_ecs_task_definition.task_efs,
    aws_alb_target_group.target_group,
    aws_alb_listener_rule.https,
    aws_iam_role_policy.ecs_autoscale_role_policy
  ]
}

resource "aws_ecs_service" "service_efs_fargate" {
  # service without LB and with Fargate
  count = var.scheduled_job ? 0 : true && var.load_balancer_enabled ? 0 : 1 && tobool(var.efs_variable["enable"]) ? 1 : 0

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = var.ecs_launch_type
  platform_version = var.ecs_fargate_platform_version

  #task_definition                    = aws_ecs_task_definition.task.arn
  task_definition                    = var.service_name
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnets_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.service_lb_fargate.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.fargate_service.arn
  }

  depends_on = [
    aws_ecs_task_definition.task_efs,
    aws_iam_role_policy.ecs_autoscale_role_policy
  ]
}

### CLOUD WATCH ###
resource "aws_cloudwatch_event_rule" "default" {
  count = var.scheduled_job ? 1 : 0
  name        = var.service_name
  description = "Terraform managed - ${var.service_name}"
  is_enabled  = true
  schedule_expression = var.ecs_schedule_expression
}

resource "aws_cloudwatch_event_target" "default" {
  count = var.scheduled_job ? 1 : 0

  target_id = var.service_name
  arn       = var.ecs_cluster_id
  rule      = aws_cloudwatch_event_rule.default[count.index].name
  role_arn  = aws_iam_role.ecs_task_execution_role.arn

  ecs_target {
    launch_type         = var.ecs_launch_type
    task_count          = "1"
    task_definition_arn = aws_ecs_task_definition.task.arn

    platform_version = var.ecs_fargate_platform_version

    network_configuration {
    subnets          = var.subnets_ids
    assign_public_ip = true
    security_groups  = [aws_security_group.service_lb_fargate.id]
    }
  }
}