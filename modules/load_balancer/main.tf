
# Create LoadBalancer
resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_app_sg.id]
  subnets            = [aws_subnet.example_subnet1.id, aws_subnet.example_subnet2.id]
}


resource "aws_lb_target_group" "web-app-target-group" {
  name     = "web-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_app_vpc.id

  health_check {
    path = "/"
  }
}

# This is optional in case we need LB to HTTP connection request.
resource "aws_lb_listener" "web_app_listener_http" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-target-group.arn
  }
}

#This will be used when domain is generated
# resource "aws_lb_listener" "web_app_listener_https" {
#   load_balancer_arn = aws_lb.web_app_lb.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08" #Subject to change
#   # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"  #Subject to change

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.web-app-target-group.arn
#   }
# }
