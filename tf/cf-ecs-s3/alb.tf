resource "aws_lb_target_group" "my_api" {
  name        = "${var.api_name}-tg"
  port        = var.api_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.api_vpc.id
  health_check {
    enabled = true
    path    = var.lb_health_check_path
  }
  depends_on = [aws_alb.my_api]
  lifecycle {
      create_before_destroy = true
    }
}

resource "aws_alb" "my_api" {
  name               = "${var.api_name}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
   ]
  security_groups = [
    aws_security_group.http.id,
    aws_security_group.egress_all.id,
   ]
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "my_api_http" {
  load_balancer_arn = aws_alb.my_api.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_api.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.my_api.dns_name}"
}