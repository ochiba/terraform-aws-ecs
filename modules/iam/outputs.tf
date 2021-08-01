output "roles" {
  value = {
    ecs_service = aws_iam_role.ecs_service
    ecs_task    = aws_iam_role.ecs_task
  }
}