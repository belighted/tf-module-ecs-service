resource "aws_ecs_task_definition" "task" {

  family = var.service_name

  container_definitions = var.template

  # check task definition parameters compatibilies
  requires_compatibilities = ["FARGATE"]

  cpu          = var.cpu
  memory       = var.memory
  network_mode = "awsvpc"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  task_role_arn = var.ecs_task_iam_role_arn
}

resource "aws_ecs_service" "service_lb_fargate" {
  # service with LB and Fargate
  count = var.load_balancer_enabled ? 1 : 0

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = "FARGATE"
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
  count = var.load_balancer_enabled ? 0 : 1

  name             = var.service_name
  cluster          = var.ecs_cluster_id
  launch_type      = "FARGATE"
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