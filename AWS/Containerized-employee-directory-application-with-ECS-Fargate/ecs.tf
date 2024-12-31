### IAM 

## Create IAM role - task role
resource "aws_iam_role" "ecs-task-role" {
  name = "ecs-dir-app-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  
}

# create an IAM role policy attachment - Amazon S3
resource "aws_iam_role_policy_attachment" "ecs-S3" {
  role       = aws_iam_role.ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# create an IAM role policy attachment - DynamoDB
resource "aws_iam_role_policy_attachment" "ecs-DynamoDB" {
  role       = aws_iam_role.ecs-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}


## Create IAM role - execution role
resource "aws_iam_role" "ecs-execution-role" {
  name = "ecs-dir-app-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  
}

# create an IAM role policy attachment - task execution role policy
resource "aws_iam_role_policy_attachment" "ecs-execution-policy" {
  role       = aws_iam_role.ecs-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


## Task Definition

resource "aws_ecs_task_definition" "ecs-dir-app" {
  family = "ecs-dir-app-V1"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 3072
  execution_role_arn       = aws_iam_role.ecs-execution-role.arn
  task_role_arn            = aws_iam_role.ecs-task-role.arn

  container_definitions = jsonencode([
    {
      name      = "employee-dir-app"
      image     = "992382381749.dkr.ecr.us-west-2.amazonaws.com/employee-directory:latest" # insert the URI of ecr image built from the Dockerfile 
      cpu       = 1024
      memory    = 3072
      essential = true
    
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80         
        }
      ]
      
    }
    
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  
}
}

## Cluster

resource "aws_ecs_cluster" "ecs-dir-app" {
  name = "ecs-dir-app"  
  
}

## Service

resource "aws_ecs_service" "ecs-dir-app" {
  name                               = "ecs-service-dir-app"
  cluster                            = aws_ecs_cluster.ecs-dir-app.id
  task_definition                    = aws_ecs_task_definition.ecs-dir-app.id
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50

  network_configuration {
    subnets          = [aws_subnet.private-01.id, aws_subnet.private-02.id]
    security_groups  = [aws_security_group.ecs-dir-app.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-dir-app.id
    container_name   = "employee-dir-app"
    container_port   = 80
  }  

}