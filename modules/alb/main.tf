resource "aws_alb" "this" {
  name = var.lb_name
  internal = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups = var.security_groups
  subnets = var.subnets
}

resource "aws_lb_target_group" "this" {
  name = "${var.lb_name}-tg"
  port = var.port
  protocol = var.protocol
  vpc_id = var.vpc_id
  target_type = var.target_type

  health_check {
    protocol = var.health_protocol
    path = var.health_check_path
  }

}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_alb.this.arn
  port = var.port
  protocol = var.protocol

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

#resource "aws_lb_target_group_attachment" "this" {
#  target_group_arn = aws_lb_target_group.this.arn
#  target_id        = var.target_id
#  port             = var.port
#  availability_zone = 
#}


#resource "aws_lb_listener" "forward-http-ip" {
#  load_balancer_arn = aws_alb.alb.arn
#  port = var.port
#  protocol = var.protocol 
#
#  default_action {
#    type = "forward"
#    target_group_arn = var.target_group_arn
#  }
#}

#resource "aws_lb_listener" "http-target-ip" {
#  count = var.create_http_listener ? 1 : 0
#  load_balancer_arn = aws_alb.alb.arn
#  port = var.port
#  protocol = "HTTP"
#
#  default_action {
#    type = "forward"
#    target_group_arn = var.target_group_arn
#  }
#}