output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "The name of the ECS cluster where the bastion task is running"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "The name of the ECS service running the bastion task"
}

output "default_security_group_id" {
  value       = var.create_default_security_group ? aws_security_group.this[0].id : null
  description = "The ID of the default security group created for the bastion task"
}