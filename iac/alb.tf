resource "aws_lb" "spectaclesxr" {
  name               = "spectaclesxr"
  internal           = false
  load_balancer_type = "application"
  subnets            = tolist(aws_subnet.public[*].id)
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "spectaclesxr" {
  name        = "spectaclesxr"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.spectaclesxr.id
  target_type = "ip"
}

resource "aws_lb_listener" "spectaclesxr_https" {
  load_balancer_arn = aws_lb.spectaclesxr.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.spectaclesxr.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spectaclesxr.arn
  }

  depends_on = [aws_lb_target_group.spectaclesxr]
}
