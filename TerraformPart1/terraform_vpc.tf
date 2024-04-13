provider "aws" {
  region = "us-east-1"
 
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraformvpc-day1"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "publicRT"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_eip" "eip" {
  domain = "vpc"
}
resource "aws_nat_gateway" "tnat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "natgw"
  }
}

resource "aws_route_table" "prvateRT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prvateRT"
  }
}

resource "aws_route_table_association" "privassociation" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.prvateRT.id
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "publicmachine" {
  ami                         =  "ami-0c7217cdde317cfec"
  instance_type               =  "t2.micro"  
  subnet_id                   =  aws_subnet.public-subnet.id
  key_name                    =  "sathya-pem"
  vpc_security_group_ids      =  ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address =  true
}
resource "aws_instance" "privatemachine" {
  ami                         =  "ami-0c7217cdde317cfec"
  instance_type               =  "t2.micro"  
  subnet_id                   =  aws_subnet.private-subnet.id
  key_name                    =  "sathya-pem"
  vpc_security_group_ids      =  ["${aws_security_group.allow_all.id}"]
  
}





