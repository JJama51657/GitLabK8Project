data "aws_eks_cluster" "helm_cluster" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "helm_cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.helm_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.helm_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.helm_cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.helm_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.helm_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.helm_cluster.token
  }
}
