provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_security_group" "allow_ssh_for_instances" {
  name        = "allow_ssh_for_instances"
  description = "allow ssh for instances"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["172.31.80.0/20"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["76.169.181.157/32", "46.98.119.18/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "webserver_template" {
  name                   = "webserver_template"
  image_id               = lookup(var.amis, var.region)
  instance_type          = "t2.micro"
  key_name               = "webservers"
  vpc_security_group_ids = [aws_security_group.allow_ssh_for_instances.id]
  user_data              = filebase64("userdata.sh")
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name_tag
      Type = var.type_tag
    }
  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  name                = "webserver_asg"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = ["subnet-32d6c21c"]
  launch_template {
    id      = aws_launch_template.webserver_template.id
    version = aws_launch_template.webserver_template.latest_version
  }

  tag {
    key                 = "Type"
    value               = var.type_tag
    propagate_at_launch = true
  }

  tag {
    key                 = "name"
    value               = var.name_tag
    propagate_at_launch = true
  }
}
