resource "aws_alb_listener_rule" "https" {
  count = var.load_balancer_enabled ? 1 : 0

  listener_arn = var.alb_listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group[0].arn
  }

  condition {
    host_header {
      values = ["${var.service_dns_name}.${var.domain}"]
    }
  }

  depends_on = [
    aws_alb_target_group.target_group
  ]
}

resource "aws_alb_listener_rule" "http" {
  count =  var.load_balancer_enabled ? 1 : 0

  listener_arn = var.alb_listener_arn_http

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  condition {
    host_header {
      values = ["${var.service_dns_name}.${var.domain}"]
    }
  }
  depends_on = [
    aws_alb_target_group.target_group
  ]
}