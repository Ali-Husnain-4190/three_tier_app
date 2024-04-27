
variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.0.0/24", "10.0.1.0/24"]
}
 
variable "private-app-subnet-cidr" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.2.0/24", "10.0.3.0/24"]
}
variable "private-db-subner-cidr" {
    type = list(string)
    description = "private subnet for database"
    default = [ "10.0.4.0/24", "10.0.5.0/24" ]
}  
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block =element(var.public_subnet_cidrs, count.index)
  tags = {
    Name="Public-web-subnet-az${count.index+1}"
  }
}

resource "aws_subnet" "private_app_subnet" {
  count      = length(var.private-app-subnet-cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block =element(var.private-app-subnet-cidr, count.index)
  tags = {
    Name="Private-app-subnet-az${count.index+1}"
  }
}
resource "aws_subnet" "private_db_subnet" {
  count = length(var.private-db-subner-cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = element(var.private-db-subner-cidr, count.index)
  tags = {
    Name="Private-app-subnet-ab${count.index+1}"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id =  aws_vpc.main.id
tags = {
    Name="igw"
    }
}
# # resource "aws_internet_gateway_attachment" "igw_attachment" {
# #   internet_gateway_id = aws_internet_gateway.igw.id
# #   vpc_id = aws_vpc.main.id
# }

resource "aws_route_table" "public_route_table_web" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
     }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

  tags = {
    Name = "public_route_table_web"
  }
}

resource "aws_route_table_association" "public_rtb_associate" {
  count= length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table_web.id
}
resource "aws_route_table" "private_route_table_db" {
  vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "10.0.0.0/16"
#     # gateway_id = aws_internet_gateway.igw.id
#      }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

  tags = {
    Name = "private_route_table_db"
  }
}

resource "aws_eip" "nat_eip" {
  vpc      = true
  count = 2
}

resource "aws_nat_gateway" "example" {
  count = 2
  allocation_id = element(aws_eip.nat_eip[*].id,count.index)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)

  tags = {
    Name = "gw NAT"
  }
}