variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "vpro-eks"
}

variable "git_repo_url" {
  description = "Git repository URL containing Kubernetes manifests"
  type        = string
  default     = "https://gitlab.com/jjama51657-group/k8cicd.git"
}

variable "git_manifests_path" {
  description = "Path within Git repo containing manifests"
  type        = string
  default     = "HelmCharts/tomcat-monitoring-chart"
}
