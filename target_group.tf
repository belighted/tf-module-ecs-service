resource "aws_alb_target_group" "target_group" {
  count = var.scheduled_job ? 0 : true && var.load_balancer_enabled ? 1 : 0

  name                 = "ecs-${var.service_name}"
  target_type          = "ip" #for Fargate only IP
  port                 = var.tg_port
  protocol             = var.tg_protocol
  vpc_id               = var.vpc_id
  deregistration_delay = var.tg_deregistration_delay

  health_check {
    port                = lookup(var.service_ports, var.service_name)
    path                = var.service_health_check_path
    matcher             = var.service_http_response_code
    interval            = var.service_health_check_interval
    timeout             = var.service_health_check_timeout
    unhealthy_threshold = var.service_health_check_unhealthy_threshold
  }

  tags = {
    Name = var.service_name
    Env  = var.environment
  }
}
