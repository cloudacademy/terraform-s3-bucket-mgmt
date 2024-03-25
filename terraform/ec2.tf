resource "aws_vpc" "lab" {
  cidr_block = "172.16.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cloudacademy-lab"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
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

resource "aws_iam_policy" "ec2_lab_policy" {
  name = "ec2-lab-policy"

  path = "/"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:List*",
        ],
        Resource = [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:*"
        ],
        Resource = [
          aws_s3_bucket.bucket1.arn,
          "${aws_s3_bucket.bucket1.arn}/*",
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_lab_role" {
  name = "ec2-lab-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_lab" {
  role       = aws_iam_role.ec2_lab_role.name
  policy_arn = aws_iam_policy.ec2_lab_policy.arn
}

resource "aws_iam_instance_profile" "ec2_lab" {
  name = "ec2-lab-profile"
  role = aws_iam_role.ec2_lab_role.name
}

resource "aws_instance" "lab" {
  ami           = data.aws_ami.amzn-linux-2023-ami.id
  instance_type = "t3.micro"

  subnet_id            = aws_subnet.private.id
  security_groups      = [aws_security_group.ssh.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_lab.name

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "lab-instance"
  }
}
