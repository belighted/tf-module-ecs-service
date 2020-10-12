resource "aws_security_group" "service_lb_fargate" {
  description = "Access to ECS fargate task"
  vpc_id      = var.vpc_id
  name        = "ecs-task-${var.service_name}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "service_lb_fargate" {
  count = length(var.sg_allow_port_range)

  description       = "access from ${var.vpc_cidr}"
  type              = "ingress"
  security_group_id = aws_security_group.service_lb_fargate.id
  cidr_blocks       = [var.vpc_cidr]
  from_port         = lookup(var.sg_allow_port_range[count.index], "from")
  protocol          = "tcp"
  to_port           = lookup(var.sg_allow_port_range[count.index], "to")
}
