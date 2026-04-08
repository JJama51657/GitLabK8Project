output "namespace" {
  value = kubernetes_namespace.opa.metadata[0].name
}
