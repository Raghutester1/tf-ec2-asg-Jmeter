resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.RAG_vpc.id

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

  tags = {
    Name = "alb_sg"
  }
}

resource "aws_lb" "my_alb" {
  name               = "aws-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  depends_on         = [aws_internet_gateway.RAG_igw]
  tags = {
    Name = "my_alb"
  }
}

resource "aws_lb_target_group" "my_target_group" {
  name        = "aws-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.RAG_vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 20
    interval            = 60
    path                = "/"
    matcher             = "200"
    port = "3000"
  }
}

resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {

    type = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
  }
}
