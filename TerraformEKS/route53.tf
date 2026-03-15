data "aws_route53_zone" "main" {
  name         = "cutsopen.co.uk"
  private_zone = false
}
