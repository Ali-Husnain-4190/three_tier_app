
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}


resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block =element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name="Public-web-subnet-az${count.index+1}"
  }
}

resource "aws_subnet" "private_app_subnet" {
  count      = length(var.private-app-subnet-cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block =element(var.private-app-subnet-cidr, count.index)
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name="Private-app-subnet-az${count.index+1}"
  }
}
resource "aws_subnet" "private_db_subnet" {
  count = length(var.private-db-subner-cidr)
  # count = lenght(var.availability_zone)
  vpc_id = aws_vpc.main.id
  
  cidr_block = element(var.private-db-subner-cidr, count.index)
  # availability_zone = {for key,res in var.availability_zone : key=>res.id}
  availability_zone = element(var.availability_zone, count.index)
  # { for key, resource in module.vpc.sg_id : key => resource.id }
  tags = {
    Name="Private-db-subnet-ab${count.index+1}"
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

resource "aws_route_table" "private_route_table_app" {
  vpc_id = aws_vpc.main.id
  # count = length(aws_nat_gateway.example)

  route {
    cidr_block = "0.0.0.0/0"
    # nat_gateway_id =element(aws_nat_gateway.example[*].id, count.index)
     nat_gateway_id = aws_nat_gateway.example[0].id

     }

#   route {
#     ipv6_cidr_block        = "::/0"
#     egress_only_gateway_id = aws_egress_only_internet_gateway.example.id
#   }

  tags = {
    Name = "private_rtb_app"
  }
}
resource "aws_route_table" "private_route_table_db" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example[1].id
  }

  tags = {
    Name = "private_rtb_db"
  }
}
resource "aws_route_table_association" "private_app_rtb_associate" {
  count          = length(var.private-app-subnet-cidr)
  subnet_id      = aws_subnet.private_app_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table_app.id
}

resource "aws_route_table_association" "private_db_rtb_associate" {
  count          = length(var.private-db-subner-cidr)
  subnet_id      = aws_subnet.private_db_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table_db.id
}