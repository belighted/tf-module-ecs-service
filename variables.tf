variable "environment" {}

variable "ecs_cluster_id" {}

variable "ecs_cluster_name" {}

variable "service_ports" {}

variable "service_name" {}

variable "domain" {}

// This will be replaced in the future
variable "ecs_task_iam_role_arn" {
  default = null
}

variable "container_name" {
  default = ""
}

variable "service_dns_name" {
  default = ""
  description = "The domain in which the header of listener will look for traffic"
}

variable "cpu" {
  default     = "256"
  description = "Fargate: values: 256, 512, 1024, 2048, 9096."

  //  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html
}

variable "cpu_threshold" {
  default = {
    scale_down = 20
    scale_up = 75
  }
  description = "CPU threshold for scaling in percents"
}

variable "memory" {
  default     = "0.5"
  description = "Fargate: vlaues: 0.5, 1, 2"
}

variable "memory_threshold" {
  default = {
    scale_down = 20
    scale_up = 85
  }
  description = "Memory threshold for scaling in percents"
}


variable "vpc_id" {
  description = "VPC ID where the task will be created"
}

variable "vpc_cidr" {
  description = "cidr for Fargate task security group"
}

variable "load_balancer_enabled" {
  default = false
}

variable "alb_listener_arn_http" {
  default = ""
}

variable "alb_listener_arn_tls" {
  default = ""
}

variable "alb_listener_arn" {
  default = ""
}

variable "cloud_map_namespace_id" {}

variable "min_capacity" {}
variable "max_capacity" {}

variable "desired_count" {
  default = 2
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}

variable "subnets_ids" {
  description = "Faragte: subnets id's for tasks"
}

variable "template" {}

variable "sg_allow_port_range" {
  description = "Alowed port ranges for incoming traffic for ECS service"
  default = [
    {
      from = "8080",
      to   = "8080"
    }
  ]
}

variable "tg_port" {
  description = "Port for target group to expose"
  default     = 8080
}

variable "tg_protocol" {
  default = "HTTP"
}

variable "tg_deregistration_delay" {
  default     = "30"
  description = "The amount time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused."
}

variable "service_health_check_path" {
  default = "/ping"
}

variable "service_http_response_code" {
  default = "200,301,302"
}

variable "service_health_check_interval" {
  default = "30"
}

variable "service_health_check_timeout" {
  default = "25"
}

variable "service_health_check_unhealthy_threshold" {
  default = "10"
}

variable "alb_dns_records_type" {
  default = "CNAME"
}

variable "ecs_fargate_platform_version" {
  default = "1.4.0"
}

variable "assign_public_ip" {
  description = "In case of not using a NAT gateway and only relay on IGW this needs to be enable if the app call external resources"
  default = true
}

variable "scheduled_job" {
  default = false
  description = "Should be the ecs scheduled task created"
}

variable "ecs_schedule_expression" {
  default = ""
  description = "The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)"
}