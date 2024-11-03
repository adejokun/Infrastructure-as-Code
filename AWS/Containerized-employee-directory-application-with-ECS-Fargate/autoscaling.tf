# Configure autoscaling using target tracking

resource "aws_appautoscaling_target" "dir-app" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs-dir-app.name}/${aws_ecs_service.ecs-dir-app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "dir-app" {
  name               = "scaling-dir-app"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dir-app.resource_id
  scalable_dimension = aws_appautoscaling_target.dir-app.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dir-app.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 65
    scale_in_cooldown = 120
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

}

