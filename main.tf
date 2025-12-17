terraform {
  backend "s3" {
    bucket = "new-bucket-for-threetier-1"
    key = "singapore"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# create a public subnet

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.public_cidr
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}public-subnet"
  }
}



# create a private subnet

resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private_cidr
  availability_zone = var.az2
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# create a private subnet for database

resource "aws_subnet" "private-subnet-b" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private_cidr_b
  availability_zone = var.az2
  tags = {
    Name = "${var.project_name}-private-subnet-b"
  }
}



# creating a internet gateway

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# creating deafault route table

resource "aws_default_route_table" "main-RT" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id
  tags = {
    Name = "${var.project_name}-main-RT"
  }
}
# add a route in main route table
resource "aws_route" "aws-route" {
  route_table_id = aws_default_route_table.main-RT.id
  destination_cidr_block = var.igw_cidr
  gateway_id = aws_internet_gateway.my_igw.id
}

# create a security group

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my-vpc.id
    name = "${var.project_name}-SG"
    description = "allow ssh, http, mysql traffic"

    ingress {
        protocol = "tcp"
        to_port = 22
        from_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    } 
    ingress {
        protocol = "tcp"
        to_port = 80
        from_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        protocol = "tcp"
        to_port = 3306
        from_port = 3306
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = -1
        to_port = 0
        from_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    depends_on = [ aws_vpc.my-vpc ] # explicit dependency
}

# create a public server

resource "aws_instance" "public_server" {
  subnet_id = aws_subnet.public-subnet.id
  ami = var.ami
  instance_type = var.instance-type
  key_name = var.key
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "${var.project_name}-web-server"
  }
  depends_on = [ aws_security_group.my_sg ]
}

# create a private server

resource "aws_instance" "app_server" {
  subnet_id = aws_subnet.private-subnet.id
  ami = var.ami
  instance_type = var.instance-type
  key_name = var.key
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "${var.project_name}-app-server"
  }
  depends_on = [ aws_security_group.my_sg ]
}

resource "aws_instance" "db_server" {
  subnet_id = aws_subnet.private-subnet-b.id
  ami = var.ami
  instance_type = var.instance-type
  key_name = var.key
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  tags = {
    Name = "${var.project_name}-db-server"
  }
  depends_on = [ aws_security_group.my_sg ]
}