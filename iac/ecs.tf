resource "aws_ecs_cluster" "spectaclesxr" {
  name = "spectaclesxr"
}

resource "aws_ecs_task_definition" "spectaclesxr" {
  family                   = "spectaclesxr"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_run.arn
  container_definitions = jsonencode([{
    name  = "spectaclesxr"
    image = "${aws_ecr_repository.spectaclesxr.repository_url}:latest"
    portMappings = [{
      containerPort = 80
      protocol      = "tcp"
    }]
  }])
}

resource "aws_ecs_service" "spectaclesxr_service" {
  name            = "spectaclesxr"
  cluster         = aws_ecs_cluster.spectaclesxr.id
  task_definition = aws_ecs_task_definition.spectaclesxr.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = tolist(aws_subnet.public[*].id)
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.spectaclesxr.arn
    container_name   = "spectaclesxr"
    container_port   = 80
  }
}
