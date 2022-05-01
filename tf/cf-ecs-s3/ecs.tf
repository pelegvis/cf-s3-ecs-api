resource "aws_ecs_cluster" "my_cluster" {
   name = "my_cluster_peleg-${var.region}"
 }

 resource "aws_ecs_task_definition" "my_api" {
  family = "my-api-peleg-${var.region}"
  execution_role_arn = aws_iam_role.my_api_task_execution_role.arn
  container_definitions = <<EOF
  [
    {
      "name": "${local.ecs_task_name}",
      "image": "${var.api_image}:latest",
      "portMappings": [
        {
          "containerPort": ${var.api_port}
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "${var.region}",
          "awslogs-group": "${aws_cloudwatch_log_group.my_api.name}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF
  cpu = 256
  memory = 512
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
}

resource "aws_cloudwatch_log_group" "my_api" {
  name = "/ecs/${var.api_name}"
}

resource "aws_iam_role" "my_api_task_execution_role" {
  name               = "${var.api_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.my_api_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

resource "aws_ecs_service" "my_api" {
  name            = "${var.api_name}-ecs-service"
  task_definition = aws_ecs_task_definition.my_api.arn
  cluster         = aws_ecs_cluster.my_cluster.id
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = aws_lb_target_group.my_api.arn
    container_name   = local.ecs_task_name
    container_port   = "${var.api_port}"
  }
  desired_count = 1
  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.egress_all.id,
      aws_security_group.ingress_api.id,
    ]
    subnets = [
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
  }
}