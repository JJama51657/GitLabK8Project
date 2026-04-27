provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = var.cluster_name
  depends_on = [module.eks]
}

data "aws_route53_zone" "main" {
  name         = "cutsopen.co.uk"
  private_zone = false
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_endpoint)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_endpoint)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", var.region]
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
}

module "external_dns" {
  source      = "./modules/external-dns"
  region      = var.region
  node_groups = module.eks.node_groups
  domain_name = data.aws_route53_zone.main.name
  depends_on  = [module.eks]
}

module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.eks]
}

module "opa" {
  source     = "./modules/opa"
  depends_on = [module.eks]
}

module "argocd_apps" {
  source             = "./modules/argocd-apps"
  argocd_namespace   = module.argocd.namespace
  git_repo_url       = var.git_repo_url
  git_manifests_path = var.git_manifests_path
  depends_on         = [module.argocd]
}

module "external_secrets" {
  source            = "./modules/eso"
  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
}
