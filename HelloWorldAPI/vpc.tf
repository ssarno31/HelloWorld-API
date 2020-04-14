resource "aws_vpc" "main_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  tags = {
    Name = "main_igw"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = "${
    map(
     "kubernetes.io/cluster/HelloWorld_API", "shared",
    )
  }"
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = "${
    map(
     "kubernetes.io/cluster/HelloWorld_API", "shared",
    )
  }"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  depends_on             = ["aws_route_table.public_route_table"]
}

resource "aws_route_table_association" "public_route_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_route_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_network_acl" "public_nacl" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    from_port  = 8080
    to_port    = 8080
    cidr_block = "10.0.0.0/16"
  }

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    from_port  = 443
    to_port    = 443
    cidr_block = "10.0.0.0/16"
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    from_port  = 8080
    to_port    = 8080
    cidr_block = "10.0.0.0/16"
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    from_port  = 443
    to_port    = 443
    cidr_block = "10.0.0.0/16"
  }

  tags = {
    Name = "main_nacl"
  }
}