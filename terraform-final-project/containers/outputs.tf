output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.app.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = try(aws_ecs_service.app[0].name, null)
}

output "eks_cluster_name" {
  description = "Optional EKS cluster name."
  value       = try(aws_eks_cluster.app[0].name, null)
}

output "eks_cluster_endpoint" {
  description = "Optional EKS cluster endpoint."
  value       = try(aws_eks_cluster.app[0].endpoint, null)
  sensitive   = true
}
