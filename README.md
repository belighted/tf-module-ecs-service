service_dns_name# How to use ECS FARGATE module

###

| Module input | Default value  | Description                                | Required parameter|
| ------------- | ------------- | ------------------------------------------ | ----------------- |
| **`source`**      | - | Location of the module (path or git)       ||
| `template`    |-| This will render the json file with vars from variables.tf ||
| `environment`    |-| Retrieved from variables.tf (stage,prod) ||
| `cpu` & `memory` |-| Amount of cpu or memory / container ( https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html ) ||
| `min_capacity` & `max_capacity` |-| Number of containers min/max in Autoscaling group ||
| `vpc_id` |-| The VPC ID where the containers will be delivered retrieved from the main backend of env-stage/env-production ||
| `vpc_cidr` |-| VPC CIDR assigned to the VPC retrieved from the main backend of env-stage/env-production ||
| `subnets_ids` |-| Subnets where the containers will get a EIN retrieved from the main backend of env-stage/env-production ||
| `ecs_cluster_id` |-| ECS Cluster ID which is retrieved from the state and was created with the ALB ||
| `ecs_iam_role`|-| ECS Role to allow executing tasks retrieved from variables.tf||
| `ecs_task_iam_role_arn`|-| ECS IAM Role arn that will allow container to make calls to other aws services like s3|no|
| `service_name` |-| ||
| `service_dns_name` |-||
| `service_health_check_path` |-|||
| `service_http_response_code` |-||
| `service_ports` |-||
| `cloud_map_namespace_id` |-||
| `domain` |-||
| `load_balancer_enabled` |-||
| `alb_listener_arn` |-||
| `alb_listener_arn_http` |-||
| `sg_allow_port_range` | [{ from = "8080", to = "8080"} ] | It is list(map(string)). Port range for AWS Security group rule on top of the ECS Fargate container service (not ELB!) which will allo traffic port starts |no|

**NOTE:** Input vars which do not have defaults defined are required by the invocation of the module.

## Release Log:
Version 0.1.0
- ECS Fargate Container
