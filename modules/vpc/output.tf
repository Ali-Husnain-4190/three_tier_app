output "vpc_id" {
  value = aws_vpc.main.id
}
output "sg_id" {
  value = aws_subnet.private_db_subnet
}
output "private_app_subnet_id" {
  value = aws_subnet.private_app_subnet
}