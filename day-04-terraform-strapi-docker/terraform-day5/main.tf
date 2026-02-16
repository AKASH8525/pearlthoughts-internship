# Security Group Module


module "security_group" {
  source       = "./modules/security-group"
  project_name = var.project_name
}


# ECR Module


module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}


# EC2 Module


module "ec2" {
  source               = "./modules/ec2"
  project_name         = var.project_name
  instance_type        = var.instance_type
  security_group_id    = module.security_group.security_group_id
  ecr_repository_url   = module.ecr.repository_url
  image_tag            = var.image_tag
  key_name             = var.key_name
}

