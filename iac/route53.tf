
resource "aws_route53_zone" "spectaclesxr" {
  name = "caffeine.casa"
}

resource "aws_route53_record" "spectaclesxr" {
  zone_id = aws_route53_zone.spectaclesxr.zone_id
  name    = "spectaclesxr.caffeine.casa"
  type    = "A"
  alias {
    name                   = aws_lb.spectaclesxr.dns_name
    zone_id                = aws_lb.spectaclesxr.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.spectaclesxr.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.spectaclesxr.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}
