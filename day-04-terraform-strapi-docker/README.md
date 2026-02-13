---

# Day 4 – Deploy Strapi on EC2 using Terraform Modules and Amazon ECR (us-east-1)

---

# 1. Project Overview

The objective of this project is to deploy a Dockerized Strapi application on AWS EC2 using modular Terraform and private Amazon ECR.

The deployment must:

* Use only the us-east-1 region
* Use the company AWS account
* Use an existing IAM role (ec2-ecr-role)
* Store Docker image in private ECR
* Be fully automated using Infrastructure as Code

The final outcome is a fully automated EC2 deployment that pulls a Docker image from private ECR and runs the Strapi application.

---

# 2. Approach

We followed this structured approach:

1. Containerized the Strapi application using Docker.
2. Verified the container locally.
3. Created modular Terraform structure.
4. Created private ECR repository.
5. Pushed Docker image to ECR.
6. Created Security Group module.
7. Created EC2 module.
8. Attached existing IAM role to EC2.
9. Automated Docker installation and ECR login using user_data.
10. Recreated EC2 to pull the final image.

This ensures a secure and fully automated deployment.

---

# 3. Terraform Project Structure

```
terraform/
│
├── provider.tf
├── main.tf
├── variables.tf
├── outputs.tf
│
└── modules/
    ├── ecr/
    ├── security-group/
    └── ec2/
```

Each component is separated into modules for clean architecture.

---

# 4. Terraform Files – Line by Line Explanation

---

## 4.1 provider.tf

```
provider "aws" {
  region  = "us-east-1"
  profile = "company"
}
```

Explanation:

* provider "aws" tells Terraform we are using AWS.
* region = "us-east-1" restricts deployment to Virginia region.
* profile = "company" ensures company credentials are used instead of personal account.

---

## 4.2 variables.tf

```
variable "project_name" {
  type    = string
  default = "strapi-devops"
}
```

Defines project name used for resource naming.

```
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

Defines EC2 instance type.

---

## 4.3 main.tf (Root Module)

```
module "ecr" {
  source       = "./modules/ecr"
  project_name = var.project_name
}
```

Calls ECR module.

```
module "security_group" {
  source       = "./modules/security-group"
  project_name = var.project_name
}
```

Calls Security Group module.

```
module "ec2" {
  source             = "./modules/ec2"
  project_name       = var.project_name
  instance_type      = var.instance_type
  security_group_id  = module.security_group.security_group_id
  ecr_repository_url = module.ecr.repository_url
}
```

Passes outputs between modules:

* Security group ID
* ECR repository URL

---

## 4.4 outputs.tf

```
output "ec2_public_ip" {
  value = module.ec2.public_ip
}
```

Displays EC2 public IP.

```
output "ecr_repository_url" {
  value = module.ecr.repository_url
}
```

Displays ECR repository URL.

---

# 5. ECR Module

---

## modules/ecr/main.tf

```
resource "aws_ecr_repository" "repo" {
  name         = var.project_name
  force_delete = true
```

Creates ECR repository and allows force deletion.

```
  image_scanning_configuration {
    scan_on_push = true
  }
```

Enables vulnerability scanning.

```
  image_tag_mutability = "MUTABLE"
```

Allows tag updates.

---

## modules/ecr/outputs.tf

```
output "repository_url" {
  value = aws_ecr_repository.repo.repository_url
}
```

Outputs ECR URL for other modules.

---

# 6. Security Group Module

---

## modules/security-group/main.tf

```
resource "aws_security_group" "this" {
```

Creates security group.

```
ingress {
  from_port = 22
```

Allows SSH.

```
ingress {
  from_port = 1337
```

Allows Strapi access.

```
egress {
  protocol = "-1"
```

Allows outbound internet access.

---

# 7. EC2 Module

---

## modules/ec2/main.tf

```
data "aws_ami" "ubuntu" {
```

Fetches latest Ubuntu 22.04 AMI.

```
resource "aws_instance" "this" {
```

Creates EC2 instance.

```
iam_instance_profile = "ec2-ecr-role"
```

Attaches existing IAM role for ECR access.

```
user_data = templatefile(...)
```

Passes ECR URL to user_data script.

---

# 8. Docker Image Preparation and Local Validation

After completing the Terraform structure, the next step was to prepare the application container.

Before pushing anything to AWS, the Docker image was built and verified locally to ensure it works correctly.

### Step 1 – Build the Docker Image

```
docker build -t strapi-devops:day4 .
```

Explanation:

* `docker build` creates a container image from the Dockerfile.
* `-t strapi-devops:day4` tags the image with a name and version.
* This image contains the production-ready Strapi application.

Building locally ensures that the container runs correctly before deploying to cloud infrastructure.

---

### Step 2 – Validate Container Locally

```
docker run -d -p 1337:1337 strapi-devops:day4
```

Explanation:

* `-d` runs the container in detached mode.
* `-p 1337:1337` maps container port to local machine.
* This verifies the application works before pushing to ECR.

The application was accessed at:

```
http://localhost:1337
```

This validation step prevents deploying broken images to ECR.

---

# 9. Creating and Using Private Amazon ECR

Once the image was verified locally, the next step was to store it securely in private Amazon ECR.

ECR was created using Terraform inside the ECR module.

After running:

```
terraform apply
```

Terraform output:

```
ecr_repository_url = 811738710312.dkr.ecr.us-east-1.amazonaws.com/strapi-devops
```

This repository URL is required to push the image.

---

### Step 1 – Authenticate Docker to Private ECR

```
aws ecr get-login-password --region us-east-1 --profile company | docker login --username AWS --password-stdin 811738710312.dkr.ecr.us-east-1.amazonaws.com
```

Explanation:

* `aws ecr get-login-password` generates a temporary authentication token.
* Docker uses this token to authenticate to private ECR.
* This avoids storing credentials in code.
* Authentication is valid temporarily and secure.

Login must succeed before pushing images.

---

### Step 2 – Tag the Image for ECR

```
docker tag strapi-devops:day4 811738710312.dkr.ecr.us-east-1.amazonaws.com/strapi-devops:latest
```

Explanation:

* The local image must be re-tagged with the full ECR repository path.
* ECR requires images to be tagged with its registry URL.
* `latest` tag is used for deployment simplicity.

---

### Step 3 – Push Image to ECR

```
docker push 811738710312.dkr.ecr.us-east-1.amazonaws.com/strapi-devops:latest
```

Explanation:

* Uploads image layers to private ECR.
* Now the image is available for EC2 to pull.
* The ECR repository now stores the production container image.

---

# 10. EC2 Bootstrapping Flow

When Terraform creates EC2, it does not manually configure anything.

Instead, automation happens through the `user_data` script.

EC2 module attaches:

```
iam_instance_profile = "ec2-ecr-role"
```

This IAM role allows EC2 to access private ECR securely.

---

### What Happens During EC2 Launch

When EC2 starts, the following occurs automatically:

1. System packages are updated.
2. Docker is installed.
3. AWS CLI is installed.
4. EC2 authenticates to ECR using IAM role.
5. Docker pulls the image from private ECR.
6. The Strapi container is started on port 1337.

This process requires no manual SSH configuration.

---

# 11. Final Synchronization Step

During initial deployment, EC2 may start before the image is pushed to ECR.

To ensure EC2 pulls the correct image, the instance is recreated:

```
terraform taint module.ec2.aws_instance.this
terraform apply
```

Explanation:

* `terraform taint` marks EC2 for recreation.
* On re-creation, EC2 runs user_data again.
* It pulls the newly pushed image from ECR.
* Ensures deployment consistency.

---

# 12. Final Application Access

After EC2 completes initialization, the application becomes available at:

```
http://<EC2_PUBLIC_IP>:1337
```

The Strapi admin interface loads successfully.

This confirms:

* ECR authentication worked.
* IAM role was correctly attached.
* Docker container is running.
* Infrastructure automation is successful.

---

