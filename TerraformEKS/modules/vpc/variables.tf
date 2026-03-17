variable "cluster_name" {
  description = "EKS cluster name for subnet tags"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}
