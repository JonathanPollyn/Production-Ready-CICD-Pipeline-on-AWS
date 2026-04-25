# -----------------------------------------------------------
# Application Load Balancer
# Public entry point for users accessing the application
# -----------------------------------------------------------

resource "aws_lb" "app" {
  name               = "${var.project_name}-${var.environment}-alb"
  load_balancer_type = "application"

  # ALB must be placed in public subnets
  subnets = aws_subnet.public[*].id

  # ALB security group allows inbound HTTP traffic
  security_groups = [aws_security_group.alb.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-alb"
  }
}

# -----------------------------------------------------------
# ALB Target Group
# Sends traffic from the ALB to ECS Fargate tasks
# -----------------------------------------------------------

resource "aws_lb_target_group" "app" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"

  # Target group must be attached to the same VPC as ECS
  vpc_id = aws_vpc.main.id

  # Health check endpoint from your Node/Express app
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-tg"
  }
}

# -----------------------------------------------------------
# HTTP Listener
# Listens on port 80 and forwards traffic to the target group
# -----------------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}