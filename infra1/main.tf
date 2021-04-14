# 1 VPC
resource "aws_vpc" "infra1" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = var.tag_name
  }
}

# 2 Internet Gateway
resource "aws_internet_gateway" "infra1" {
  vpc_id = aws_vpc.infra1.id

  tags = {
    Name = var.tag_name
  }
}

# 3 Route table
resource "aws_route_table" "infra1" {
  vpc_id = aws_vpc.infra1.id

  route {
    cidr_block = "0.0.0.0/0" # IPv4
    gateway_id = aws_internet_gateway.infra1.id
  }

  tags = {
    Name = var.tag_name
  }
}

# 4 Subnets
resource "aws_subnet" "infra1_subnet1" {
  vpc_id     = aws_vpc.infra1.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.tag_name} - Subnet 1"
  }
}

resource "aws_subnet" "infra1_subnet2" {
  vpc_id     = aws_vpc.infra1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.tag_name} - Subnet 2"
  }
}

resource "aws_subnet" "infra1_subnet3" {
  vpc_id     = aws_vpc.infra1.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.tag_name} - Subnet 3"
  }
}

# 5 Association Subnet / Route table
resource "aws_route_table_association" "infra1" {
  subnet_id      = aws_subnet.infra1_subnet1.id
  route_table_id = aws_route_table.infra1.id
}

# 6 Security Group for HTTP and SSH
resource "aws_security_group" "infra1" {
  name        = "allow_web"
  description = "Allow Http and SSH Traffic"
  vpc_id      = aws_vpc.infra1.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere"
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

  tags = {
    Name = var.tag_name
  }
}

# 7 Elastic Network Interface (ENI)
resource "aws_network_interface" "infra1" {
  subnet_id       = aws_subnet.infra1_subnet1.id
  private_ips     = [var.private_ip]
  security_groups = [aws_security_group.infra1.id]

  tags = {
    Name = var.tag_name
  }
}

# 8 Elastic IP
resource "aws_eip" "infra1" {
  vpc                       = true
  network_interface         = aws_network_interface.infra1.id
  associate_with_private_ip = var.private_ip
  depends_on                = [aws_internet_gateway.infra1]

  tags = {
    Name = var.tag_name
  }
}

# 9 EC2 Web server
resource "aws_instance" "infra1" {
  ami = var.ami_id
  instance_type = "t2.micro"
  #availability_zone = "${var.region}a"
  key_name = "infra1_chris"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.infra1.id
  }

  user_data = file("install_apache.sh")

  tags = {
    Name = var.tag_name
  }
}


# 10 DB server (instance RDS)
resource "aws_db_instance" "infra1" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "infra1"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.infra1.name
  #vpc_security_group_ids = [aws_security_group.infra1.id]
}

# 11 DB Subnet Group
resource "aws_db_subnet_group" "infra1" {
  name = "infra1"
  subnet_ids = [aws_subnet.infra1_subnet1.id, aws_subnet.infra1_subnet2.id, aws_subnet.infra1_subnet3.id]
}