resource "aws_ecr_repository" "repo" {
  name         = var.project_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Name = var.project_name
  }
}
