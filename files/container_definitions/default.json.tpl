[
  {
    "name": "${container_name}",
    "image": "${image_location}",
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory_reservation},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${container_port},
        "hostPort": ${host_port},
        "protocol": "tcp"
      }
    ],
    "environment": [],
    "secrets": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${log_region}",
        "awslogs-stream-prefix": "${log_prefix}"
      }
    }
  }
]