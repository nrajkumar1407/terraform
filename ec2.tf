resource "aws_instance" "docker_host" {

  ami           = "ami-12345678"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.docker_sg.id
  ]

iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash

              apt update

              apt install -y docker.io

              systemctl enable docker
              systemctl start docker

              docker run -d \
                -p 80:80 \
                nginx
              EOF


  tags = {
    Name = "docker-server"
  }
}
