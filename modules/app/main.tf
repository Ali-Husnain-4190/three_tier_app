resource "aws_security_group" "app_sg" {
 name        = "app_sg"
 description = "Allow SSH to app server"
 vpc_id      = var.vpc_id

ingress {
   description = "app ingress role"
   from_port   = 22
   to_port     = 22
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
resource "aws_launch_template" "app_template" {
  name = "app_tempalte"
  description = "app_template"
  image_id= "ami-04ff98ccbfa41c9ad"
  instance_type="t2.micro"
#   vpc_security_group_ids=[aws_security_group.app_sg.id]
  ebs_optimized = false
#   network_interfaces {
#     associate_public_ip_address = false
#     subnet_id                   = var.subnet_id[0]  # Add your subnet ID here
#     security_groups             = [aws_security_group.app_sg.id]
#   }
#   block_device_mappings {
#     device_name = "/dev/sdf"

#     ebs {
#       volume_size = 20
#     }
#   }
    monitoring {
    enabled = true
  }
}


# resource "aws_autoscaling_group" "asg" {
#   name                 = "autoscaling-group"
#   launch_template {
#     id      = aws_launch_template.app_template.id
#     version = "$Latest"
#   }

# #   availability_zones    = ["us-east-1a,us-east-1b"]
#   min_size             = 1      
#   max_size             = 1     
#   desired_capacity     = 1      
#   vpc_zone_identifier  = [ var.subnet_ids[0], var.subnet_ids[1]] 
#   health_check_type    = "EC2"  
#   health_check_grace_period = 300 
# #   target_group_arns         = ["${aws_lb_target_group.alb-tg.arn}"]

#  tag {
#      key                 = "Name"
#      value               = "ec2"
#      propagate_at_launch = true
#   }
# }