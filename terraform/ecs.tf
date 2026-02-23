resource "aws_ecs_cluster" "cluster" {
  name = "strapi-cluster"
}


resource "aws_cloudwatch_log_group" "logs" {
  name = "/ecs/strapi"
}


resource "aws_ecs_task_definition" "task" {
  family                   = "strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "strapi"
    image = "${var.ecr_image_url}"

    portMappings = [{
      containerPort = 1337
      protocol      = "tcp"
    }]

    environment = [
      { name = "NODE_ENV", value = "production" },

      { name = "HOST", value = "0.0.0.0" },
      { name = "PORT", value = "1337" },

      { name = "APP_KEYS", value = "O+wgDCfABBdYxltAMn2xMQ==,pS8/nO1VXGwHxObMAeSieA==,VbPLjcx6OmebmeTOkOAhZA==,vqbGyt9evPn+ttVQXYsk7A==" },

      { name = "API_TOKEN_SALT", value = "vrm7FLzWllB8z9dgKlvhHg==" },
      { name = "ADMIN_JWT_SECRET", value = "9EnO7MssH7KS1M4soCPr7w==" },
      { name = "TRANSFER_TOKEN_SALT", value = "PzAYPimU70mwVtvBYOPTcA==" },
      { name = "ENCRYPTION_KEY", value = "EOt5rlBh8UX29kWl0xvklQ==" },
      { name = "JWT_SECRET", value = "IXaypxgV1Ucw6z2RFyF4PA==" },

      { name = "DATABASE_CLIENT", value = "sqlite" },
      { name = "DATABASE_FILENAME", value = ".tmp/data.db" }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.logs.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}


resource "aws_ecs_service" "service" {
  name            = "strapi-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "strapi"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.listener]
}
