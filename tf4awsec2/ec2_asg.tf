resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.RAG_vpc.id

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id] # Only allow traffic from ALB
    #cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}

resource "aws_launch_template" "my_template" {
  name_prefix   = "ec2_template_"
  image_id      = "ami-085f9c64a9b75eed5" # Adjust AMI as needed
  instance_type = var.instance_type

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.private_subnet1.id
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm
              sudo apt-get install -y git
              git clone https://github.com/johnpapa/node-hello.git /home/ubuntu/node-app
              cd /home/ubuntu/node-app
              npm install
              nohup node index.js &
              EOF
  )    
}
# npm install
#               nohup node index.js &
# sudo apt-get update -y
#               sudo apt-get install -y python3 python3-pip git
#               sudo mkdir -p /home/ubuntu/sampleflaskapp
#               sudo git clone https://github.com/Raghutester1/sampleflaskapp.git /home/ubuntu/sampleflaskapp
#               cd /home/ubuntu/sampleflaskapp
#               sudo pip3 install -r requirements.txt
#               nohup sudo python3 hello.py &
# sudo apt-get install nodejs git -y
#               git clone https://github.com/johnpapa/node-hello.git /home/ubuntu/node-hello
#               cd /home/ubuntu/node-hello
#               npm install
#               npm start
# on 24.9.2024 
# nohup npm run start -- -H 0.0.0.0 -p 3000 &
resource "aws_autoscaling_group" "my_asg" {
  name                 = "RAG_asg"
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  launch_template {
    id      = aws_launch_template.my_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.my_target_group.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}

# Auto Scaling Policy - Scale out when CPU usage exceeds 60%
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

# Auto Scaling Policy - Scale in when CPU usage is below 30%
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
}

resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_name                = "scale-out-alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 3
  alarm_description         = "Alarm when CPU utilization exceeds 60%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

# CloudWatch Alarm for CPU Utilization (Scale In)
resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_name                = "scale-in-alarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 10
  alarm_description         = "Alarm when CPU utilization goes below 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

