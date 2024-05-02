variable "vpc_cidr" {
  type = string
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private-app-subnet-cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}
variable "private-db-subner-cidr" {
  type        = list(string)
  description = "private subnet for database"
}
variable "availability_zone" {
  type = list(string)
  # default = 
}
