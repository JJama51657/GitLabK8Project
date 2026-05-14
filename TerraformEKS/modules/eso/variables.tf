variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "secret_prefix" {
  description = "Prefix of the Secrets Manager secrets this role is allowed to read"
  type        = string
}
