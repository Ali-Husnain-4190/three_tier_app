# Define IAM Role
# resource "aws_iam_role" "ssm_role" {
#   name = "example-role"
#   assume_role_policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [{
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }]
#   })

#   # Define Inline Policy
#   inline_policy {
#     name = "example-inline-policy"
#     policy = jsonencode({
#       "Version": "2012-10-17",
#       "Statement": [{
#           "Effect": "Allow",
#           "Action": [
#               "ssm:DescribeAssociation",
#               "ssm:GetDeployablePatchSnapshotForInstance",
#               "ssm:GetDocument",
#               "ssm:DescribeDocument",
#               "ssm:GetManifest",
#               "ssm:GetParameter",
#               "ssm:GetParameters",
#               "ssm:ListAssociations",
#               "ssm:ListInstanceAssociations",
#               "ssm:PutInventory",
#               "ssm:PutComplianceItems",
#               "ssm:PutConfigurePackageResult",
#               "ssm:UpdateAssociationStatus",
#               "ssm:UpdateInstanceAssociationStatus",
#               "ssm:UpdateInstanceInformation"
#           ],
#           "Resource": "*"
#       },
#       {
#           "Effect": "Allow",
#           "Action": [
#               "ssmmessages:CreateControlChannel",
#               "ssmmessages:CreateDataChannel",
#               "ssmmessages:OpenControlChannel",
#               "ssmmessages:OpenDataChannel"
#           ],
#           "Resource": "*"
#       },
#       {
#           "Effect": "Allow",
#           "Action": [
#               "ec2messages:AcknowledgeMessage",
#               "ec2messages:DeleteMessage",
#               "ec2messages:FailMessage",
#               "ec2messages:GetEndpoint",
#               "ec2messages:GetMessages",
#               "ec2messages:SendReply"
#           ],
#           "Resource": "*"
#       }]
#     })
#   }
# }


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
  # iam_instance_profile {
  #   name=aws_iam_role.ssm_role.name
  # }
  network_interfaces {
    associate_public_ip_address = false
    # subnet_ids                   = [var.subnet_id[0]  # Add your subnet ID here
    security_groups             = [aws_security_group.app_sg.id]
  }
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
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id
  
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

resource "aws_lb_target_group" "alb-tg" {
  name        = "tf-example-lb-alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
}
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.subnet_ids[0],var.subnet_ids[1]]

  enable_deletion_protection = false

}
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}





resource "aws_autoscaling_group" "asg" {
  name                 = "autoscaling-group"
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }
  vpc_zone_identifier=var.subnet_ids

#   availability_zones    = ["us-east-1a,us-east-1b"]
  min_size             = 1      
  max_size             = 2     
  desired_capacity     = 2      

  health_check_type    = "EC2"  
  health_check_grace_period = 300 
#   target_group_arns         = ["${aws_lb_target_group.alb-tg.arn}"]

 tag {
     key                 = "Name"
     value               = "ec2"
     propagate_at_launch = true
  }
}