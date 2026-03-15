variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "clusterName" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vpro-eks"
}

variable "git_repo_url" {
  description = "Git repository URL containing Kubernetes manifests"
  type        = string
  default     = "https://gitlab.com/jjama51657-group/k8cicd.git"
}

variable "git_target_revision" {
  description = "Git branch/tag to track"
  type        = string
  default     = "main"
}

variable "git_manifests_path" {
  description = "Path within Git repo containing manifests"
  type        = string
  default     = "HelmCharts/tomcat-monitoring-chart"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "vprofile"
}
