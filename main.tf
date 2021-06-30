provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "ingressrules" {
  type    = list(number)
  default = [22, 80]
}

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

data "aws_ami" "ubuntu" {

}

resource "aws_instance" "linux-server-docker" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_traffic.name]
  key_name        = "linux"

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo tee /etc/yum.repos.d/docker.repo <<-'EOF' [dockerrepo]
       name=Docker Repository
       baseurl=https://yum.dockerproject.org/repo/main/centos/7/
       enabled=1
       gpgcheck=1
       gpgkey=https://yum.dockerproject.org/gpg
       EOF",
      "sudo yum install docker-engine -y",
      "sudo service docker start",
    ]
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/linux.pem")
  }

  tags = {
    "Name"      = "linux-server-docker"
    "Terraform" = "true"
  }
}
