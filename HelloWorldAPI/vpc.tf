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
     "Name", "public_subnet_1", 
     "kubernetes.io/cluster/HelloWorld_API", "shared",
    )
  }"
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = "${aws_vpc.main_vpc.id}"
  cidr_block = "10.0.2.0/24"

  tags = "${
    map(
     "Name", "public_subnet_2", 
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

resource "aws_route_table_association" "public_route_1" {
  subnet_id      = "${aws_subnet.public_subnet_1.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_route_2" {
  subnet_id      = "${aws_subnet.public_subnet_2.id}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_network_acl" "main_nacl" {
    vpc_id     = "${aws_vpc.main_vpc.id}"
    subnet_ids = ["${aws_subnet.public_subnet_1.id}",
     "${aws_subnet.public_subnet_2.id}"]

    ingress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    egress {
        from_port  = 0
        to_port    = 0
        rule_no    = 100
        action     = "allow"
        protocol   = "-1"
        cidr_block = "0.0.0.0/0"
    }

    tags {
        "Name" = "main_nacl"
    }
}
