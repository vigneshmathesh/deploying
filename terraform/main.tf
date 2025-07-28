provider "aws" {
  region = "us-east-1"
}

resource "random_id" "key" {
  byte_length = 4
}

resource "aws_key_pair" "scale" {
  key_name   = "scale-${random_id.key.hex}"
  public_key = file("${path.module}/id_rsa.pub")
}

resource "aws_security_group" "flask_sg" {
  name = "flask-sg-${random_id.key.hex}"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
}
resource "aws_instance" "flask_app" {
  ami                         = "ami-020cba7c55df1f615" # Ubuntu 20.04
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.scale.key_name
  subnet_id                   = "subnet-06978bf9d73ff38f7"
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install docker.io -y
              sudo systemctl start docker
              sudo docker run -d -p 5000:5000 sakthi965
              EOF

  tags = {
    Name = "my-instance"
  }
}
