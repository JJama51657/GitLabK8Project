output "argocd_server_url" {
  description = "ArgoCD Server URL"
  value       = "https://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_admin_password" {
  description = "ArgoCD Admin Password"
  value       = nonsensitive(data.kubernetes_secret.argocd_admin.data["password"])
  sensitive   = false
}

output "argocd_login_command" {
  description = "Command to login to ArgoCD CLI"
  value       = "argocd login ${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname} --username admin --password ${nonsensitive(data.kubernetes_secret.argocd_admin.data["password"])} --insecure"
}
