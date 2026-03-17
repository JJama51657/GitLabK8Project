output "namespace" {
  value = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_url" {
  value = "https://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}"
}

output "argocd_admin_password" {
  value = nonsensitive(data.kubernetes_secret.argocd_admin.data["password"])
}

output "argocd_login_command" {
  value = "argocd login ${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname} --username admin --password ${nonsensitive(data.kubernetes_secret.argocd_admin.data["password"])} --insecure"
}
