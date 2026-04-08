resource "kubernetes_namespace" "opa" {
  metadata {
    name = "gatekeeper-system"
  }
}

resource "helm_release" "opa_gatekeeper" {
  name       = "gatekeeper"
  repository = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart      = "gatekeeper"
  namespace  = kubernetes_namespace.opa.metadata[0].name
  version    = "3.14.0"

  set {
    name  = "auditInterval"
    value = "60"
  }

  set {
    name  = "violationLimit"
    value = "20"
  }

  depends_on = [kubernetes_namespace.opa]
}
