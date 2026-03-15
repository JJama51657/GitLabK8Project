resource "kubernetes_manifest" "vprofile_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "vprofile-app"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.git_repo_url
        targetRevision = "main"
        path           = var.git_manifests_path
        helm = {
          releaseName = "vprofile"
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "vprofile-prod"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  computed_fields = ["metadata.finalizers", "metadata.labels", "metadata.annotations"]

  depends_on = [helm_release.argocd, module.eks]
}

resource "kubernetes_manifest" "vprofile_app_dev" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "vprofile-app-dev"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.git_repo_url
        targetRevision = "dev"
        path           = var.git_manifests_path
        helm = {
          releaseName = "vprofile-dev"
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "vprofile-dev"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  computed_fields = ["metadata.finalizers", "metadata.labels", "metadata.annotations"]

  depends_on = [helm_release.argocd, module.eks]
}

resource "kubernetes_manifest" "vprofile_app_test" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "vprofile-app-test"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"

      source = {
        repoURL        = var.git_repo_url
        targetRevision = "test"
        path           = var.git_manifests_path
        helm = {
          releaseName = "vprofile-test"
        }
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "vprofile-test"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  computed_fields = ["metadata.finalizers", "metadata.labels", "metadata.annotations"]

  depends_on = [helm_release.argocd, module.eks]
}
