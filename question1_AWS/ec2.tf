# Setup our aws provider
provider "aws" {
  access_key  = "${var.aws_access_key_id}"
  secret_key  = "${var.aws_secret_access_key}"
  region      = "${var.vpc_region}"
}

# SSH key pair for accessing ec2 machine
resource "aws_key_pair" "sshKeyPair" {
  key_name   = "${var.aws_key_name}"
  public_key = "${var.public_ssh_key}"
}

# instances
resource "aws_instance" "ec2Instances" {
  count = 1
  ami = "${var.inst_ami}"
  availability_zone = "${lookup(var.availability_zone, var.vpc_region)}"
  instance_type = "${var.inst_type}"
  key_name = "${aws_key_pair.sshKeyPair.key_name}"
  subnet_id = "${var.vpc_public_sn_id}"
  associate_public_ip_address = true
  source_dest_check = false

  security_groups = [
    "${var.vpc_public_sg_id}"]

  tags = {
    Name = "ec2Instances${count.index}"
  }
}

output "ec2_ins_0_ip" {
  value = "${aws_instance.ec2Instances.0.public_ip}"
}

#implememnt zero downtime
 lifecycle {
    create_before_destroy = true
  }

# Create a new load balancer
resource "aws_elb" "lbcer" {
  name               = "foobar-terraform-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  access_logs {
    bucket        = "foo"
    bucket_prefix = "lbcer"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}