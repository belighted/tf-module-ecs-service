data "aws_acm_certificate" "certificate" {
  #domain   = "*.${var.domain}"
  domain = var.aws_acm_domain
  statuses = ["ISSUED"]
}
