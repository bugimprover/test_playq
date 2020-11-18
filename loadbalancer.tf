resource "aws_security_group" "sg_for_lb" {
  name        = "sg_for_lb"
  description = "allow http from everywhere"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "web_elb" {
  name            = "web-elb"
  security_groups = [aws_security_group.sg_for_lb.id]
  subnets         = ["subnet-32d6c21c", "subnet-82c41dcf"]

}

resource "aws_lb_target_group" "my_tg" {
  name     = "my-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-9cc59fe6"
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    matcher             = 200
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_elb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "500: Internal Server Error"
      status_code  = 500
    }
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.webserver_asg.id
  alb_target_group_arn   = aws_lb_target_group.my_tg.arn
}

resource "aws_lb_listener_rule" "forward_by_header" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_tg.arn
  }

  condition {
    host_header {
      values = ["*.amazonaws.com"]
    }
  }
}
