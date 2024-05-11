resource "aws_launch_template" "web_template" {
  name = "web_tempalte"
  description = "web_tempalte"
  image_id= "ami-04ff98ccbfa41c9ad"
  instance_type="t2.micro"
#   vpc_security_group_ids=[aws_security_group.app_sg.id]
  ebs_optimized = false
 
    monitoring {
    enabled = true
  }
}


resource "aws_autoscaling_group" "asg" {
  name = "web-app-auto-scaling-group"  # Removed trailing space from the name
  
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
  vpc_zone_identifier   = var.subnet_ids
  # availability_zones    = ["us-east-1a,us-east-1b"]
  min_size              = 1      
  max_size              = 2     
  desired_capacity      = 2      
  health_check_type     = "EC2"  
  health_check_grace_period = 300 
  # target_group_arns     = ["${aws_lb_target_group.alb-tg.arn}"]

  tag {
    key                 = "Name"
    value               = "ec2-web"
    propagate_at_launch = true
  }
}
