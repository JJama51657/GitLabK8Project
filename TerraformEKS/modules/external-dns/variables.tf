variable "region" {
  description = "AWS region"
  type        = string
}

variable "node_groups" {
  description = "EKS managed node groups"
}

variable "domain_name" {
  description = "Route53 hosted zone domain name"
  type        = string
}
