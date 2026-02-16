data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]

  iam_instance_profile = "ec2-ecr-role"

  user_data = templatefile("${path.module}/user_data.sh", {
    ecr_url   = var.ecr_repository_url
    image_tag = var.image_tag
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

