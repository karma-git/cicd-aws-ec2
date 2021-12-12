// PROVIDER
provider "aws" {
  region  = var.REGION
  profile = var.PROFILE
}

// VARIABLES

variable "REGION" {}

variable "PROFILE" {}

variable "public_key_path" {}

variable "private_key_path" {}

locals {
  project = "demo-deployment"
  tag = {
      Name = "demo-deployment"
      Created = "Terraform"
  }
}

// DATA SOURCES

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] // Canonical

  filter {
    name   = "description"
    values = ["Canonical, Ubuntu, 20.04 LTS, amd64 focal image build on*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

// RESOURCES

resource "aws_security_group" "this" {
  name   = "${local.project}-sg"
  description = "Allow ssh and web on port 8080, and answer to everyone"
  vpc_id = data.aws_vpc.default.id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    // web
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    // Allow outgoing traffic from all ports
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tag
}

resource "aws_key_pair" "this" {
  key_name   = local.project
  public_key = file(var.public_key_path)

  tags = local.tag
}

/*

Let's try to deal with the instance for the first iteration
# TODO: provision via ASG

resource "aws_launch_configuration" "this" {
  name   = "${local.project}-lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true

  key_name        = aws_key_pair.this.id
  security_groups = [aws_security_group.this.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = "${local.project}-asg"
  launch_configuration = aws_launch_configuration.this.name

  vpc_zone_identifier = data.aws_subnet_ids.default.ids

  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  lifecycle {
    create_before_destroy = true
  }
  // FIXME tags don't work
  tags = [local.tag]
}
*/

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

#   subnet_id              = aws_subnet.this.id
  vpc_security_group_ids = [aws_security_group.this.id]
  availability_zone      = "${var.REGION}b"

  associate_public_ip_address = true
  key_name                    = aws_key_pair.this.key_name

  // user_data = file("../scripts/install_docker_engine.sh")

  provisioner "remote-exec" {
    script = "./scripts/wait_for_instance.sh"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {
    command = <<EOF
        ansible-playbook \
          --inventory '${self.public_ip},' \
          --private-key ${var.private_key_path} \
          --user ubuntu \
          ./ansible/playbook.yml
        EOF

  }

  tags = local.tag
}

// OUTPUT
output "eip" {
  value       = aws_instance.this.public_ip
}
