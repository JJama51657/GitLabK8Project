# fetch the EKS cluster so we can extract its OIDC issuer URL for the trust policy
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  values = [
    yamlencode({
      installCRDs = true # installs Certificate, ClusterIssuer CRDs — without this the Helm chart templates would fail to apply

      serviceAccount = {
        create = true
        name   = "cert-manager"
        annotations = {
          # this annotation is the IRSA link — EKS pod identity webhook sees this and mounts a
          # projected service account token into the pod, which is exchanged with STS for short-lived AWS credentials
          "eks.amazonaws.com/role-arn" = aws_iam_role.cert_manager.arn
        }
      }
    })
  ]
}

resource "aws_iam_role" "cert_manager" {
  name = "eks-cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn # only tokens issued by this cluster's OIDC provider are trusted
        }
        Action = "sts:AssumeRoleWithWebIdentity" # pod presents its service account token, STS validates and returns temp credentials
        Condition = {
          StringEquals = {
            # locks the role to ONLY the cert-manager service account in the cert-manager namespace
            # no other pod in the cluster can assume this role even if they reference the same role ARN
            "${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cert_manager" {
  name = "cert-manager-route53-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange",                # polls the TXT record change status until it propagates across DNS
          "route53:ChangeResourceRecordSets",  # writes the _acme-challenge TXT record so Let's Encrypt can validate domain ownership
          "route53:ListResourceRecordSets"     # reads existing records in the zone
        ]
        Resource = [
          "arn:aws:route53:::hostedzone/${var.route53_zone_id}", # scoped to your specific hosted zone only
          "arn:aws:route53:::change/*"                           # required for GetChange to poll propagation status
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["route53:ListHostedZones"] # cert-manager uses this to find the right hosted zone by domain name
        Resource = "*"                         # must be * — ListHostedZones does not support resource-level restrictions
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn # attaches the Route53 policy to the role the cert-manager pod assumes via IRSA
}
