locals {
  ecs_vars = {
    cluster_name       = "${var.stack_prefix}-${var.ecs.container_name}-cluster"
    service_name       = "${var.stack_prefix}-${var.ecs.container_name}-service"
    task_name          = "${var.stack_prefix}-${var.ecs.container_name}-task"
    container_name     = "${var.stack_prefix}-${var.ecs.container_name}"
    image_location     = "nginx:latest"
    cpu                = var.ecs.cpu
    memory             = var.ecs.memory
    memory_reservation = var.ecs.memory_reservation
    container_port     = var.ecs.container_port
    host_port          = var.ecs.host_port
    log_group          = "/${var.stack_prefix}/usr/ecs"
    log_region         = var.region
    log_prefix         = var.ecs.container_name
  }
}