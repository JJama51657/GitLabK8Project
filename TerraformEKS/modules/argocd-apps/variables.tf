variable "argocd_namespace" {
  description = "ArgoCD namespace"
  type        = string
}

variable "git_repo_url" {
  description = "Git repository URL"
  type        = string
}

variable "git_manifests_path" {
  description = "Path to helm charts in git repo"
  type        = string
}
