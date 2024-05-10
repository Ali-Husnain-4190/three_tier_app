# // SG for RDS
resource "aws_security_group" "rds_sg" {
 name        = "web-server-sg-tf"
 description = "Allow HTTPS to web server"
 vpc_id      = var.vpc_id

ingress {
   description = "mysql ingress role"
   from_port   = 3306
   to_port     = 3306
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
resource "aws_db_instance" "mysql" {
  allocated_storage = 10
  engine = "mysql"
  instance_class = "db.t3.micro"
  username = "foo"
  password = "foobarbaz"

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  skip_final_snapshot = true // required to destroy
}
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet-group"
  # availability_zone = element(var.availability_zone, count.index)
  # subnet_ids = { for key, resource in var.sg_ids : key => resource.id }
    # cidr_block =element(var.public_subnet_cidrs, count.index)
  
  subnet_ids= var.subnet_ids

  tags = {
    Name = "My DB Subnet Group"
  }
}

# # output "sg_id" {
# #   # value=length(var.sg_ids)
# #   value = { for key, resource in var.sg_ids : key => resource.id }
# # }