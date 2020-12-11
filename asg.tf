# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU High
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = !var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = lookup(var.cpu_threshold,"scale_up" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up_policy_cpu[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high_lb" {
  count               =  var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = lookup(var.cpu_threshold,"scale_up" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up_policy_cpu_lb[0].arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm CPU Low
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               =  !var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = lookup(var.cpu_threshold,"scale_down" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down_policy_cpu[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low_lb" {
  count               = var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = lookup(var.cpu_threshold,"scale_down" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down_policy_cpu_lb[0].arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm Memory High
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = !var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = lookup(var.memory_threshold,"scale_up" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up_policy_memory[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_high_lb" {
  count               = var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-memory-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = lookup(var.memory_threshold,"scale_up" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up_policy_memory_lb[0].arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - CloudWatch Alarm Memory Low
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = !var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-memory-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = lookup(var.memory_threshold,"scale_down" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down_policy_memory[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "memory_low_lb" {
  count               = var.load_balancer_enabled ? 1 : 0
  alarm_name          = "${var.service_name}-memory-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = lookup(var.memory_threshold,"scale_down" )

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down_policy_memory_lb[0].arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Target
# ---------------------------------------------------------------------------------------------------------------------

### for targets that have load balancer the service is service_fargate and that needs to be created in advance!
resource "aws_appautoscaling_target" "scale_target" {
  count              = !var.load_balancer_enabled ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.ecs_autoscale_role.arn
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  depends_on = [
    aws_ecs_service.service_fargate
  ]
}

### for targets that does not have load balancer the service is service_lb_fargate and that needs to be created in advance!
resource "aws_appautoscaling_target" "scale_target_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.ecs_autoscale_role.arn
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  depends_on = [
    aws_ecs_service.service_lb_fargate
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy CPU
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy_cpu" {
  count              = !var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-up-policy-cpu"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target
  ]
}

resource "aws_appautoscaling_policy" "scale_up_policy_cpu_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-up-policy-cpu"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target_lb
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy CPU
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy_cpu" {
  count              = !var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-${var.environment}-scale-down-policy-cpu"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target
  ]
}

resource "aws_appautoscaling_policy" "scale_down_policy_cpu_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-down-policy-cpu"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target_lb
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Up Policy Memory
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_up_policy_memory" {
  count              = !var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-up-policy-mem"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target
  ]
}

resource "aws_appautoscaling_policy" "scale_up_policy_memory_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-up-policy-mem"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target_lb
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Auto Scaling - Scaling Down Policy Memory
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_appautoscaling_policy" "scale_down_policy_memory" {
  count              = !var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-down-policy-mem"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target
  ]
}

resource "aws_appautoscaling_policy" "scale_down_policy_memory_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  name               = "${var.service_name}-scale-down-policy-mem"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    aws_appautoscaling_target.scale_target_lb
  ]
}
