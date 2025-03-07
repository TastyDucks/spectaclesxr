resource "aws_acm_certificate" "spectaclesxr" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "spectaclesxr" {
  certificate_arn         = aws_acm_certificate.spectaclesxr.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.name]
}
