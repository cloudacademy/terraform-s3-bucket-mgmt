resource "aws_vpc" "lab" {
  cidr_block = "172.16.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "cloudacademy-lab"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-west-2a"

  tags = {
    name = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id

  tags = {
    name = "private-zone"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.lab.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.lab.id
  service_name = "com.amazonaws.us-west-2.s3"

  tags = {
    environment = "S3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_ec2_instance_connect_endpoint" "instance_connect_ep" {
  subnet_id          = aws_subnet.private.id
  security_group_ids = [aws_security_group.ssh.id]
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_iam_instance_profile" "ec2_lab" {
  name = "ec2-labinstance-profile"
  role = "ec2-labinstance-role"
}

resource "aws_instance" "lab" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ssh.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_lab.name

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    name = "lab-instance"
    type = "privately-zoned"
  }
}
