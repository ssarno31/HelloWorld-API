resource "aws_security_group" "eks_security_group" {
  name        = "allow_https"
  description = "Allow https over 443 inbound traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  },

  tags = {
    Name = "allow_http_ssh"
  }
}