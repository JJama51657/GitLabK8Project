output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "region" {
  description = "AWS Region"
  value       = var.region
}

output "cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = module.eks.cluster_security_group_id
}

output "argocd_server_url" {
  description = "ArgoCD Server URL"
  value       = module.argocd.argocd_server_url
}

output "argocd_admin_password" {
  description = "ArgoCD Admin Password"
  value       = module.argocd.argocd_admin_password
}

output "argocd_login_command" {
  description = "ArgoCD CLI login command"
  value       = module.argocd.argocd_login_command
}
