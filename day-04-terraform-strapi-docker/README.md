
---

# Day 4 – Deploy Strapi on EC2 using Terraform and Docker

## 1. Objective

The objective of this task is to automate the deployment of a Strapi application on AWS EC2 using Docker and Terraform.

The entire infrastructure and application setup is provisioned automatically using Infrastructure as Code (Terraform). No manual configuration was performed on the EC2 instance.

---

## 2. Architecture Overview

The deployment flow is as follows:

1. Strapi application is containerized using Docker.
2. Docker image is pushed to Docker Hub.
3. Terraform provisions:

   * Security Group
   * EC2 instance
4. EC2 executes a user_data script that:

   * Installs Docker
   * Pulls the Docker image from Docker Hub
   * Runs the Strapi container
5. Strapi becomes accessible via the EC2 Public IP on port 1337.

This ensures a fully automated deployment process.

---

## 3. Tools and Technologies Used

* Ubuntu 24.04 LTS (WSL)
* Docker
* Docker Hub
* Terraform
* AWS EC2
* AWS IAM
* Git and GitHub

---

## 4. Project Structure

```
day-04-terraform-strapi-docker/
│
├── strapi-app/
│   ├── Dockerfile
│   └── Strapi source code
│
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── user_data.sh
│
└── README.md
```

---

## 5. Docker Implementation

### Dockerfile

The Strapi application was containerized using a Node.js base image:

* Base Image: node:20-bullseye
* Production dependencies installed
* Admin panel built
* Application runs in production mode
* Port 1337 exposed

# Dockerfile Explanation 

This section explains each instruction used in the Dockerfile for containerizing the Strapi application.

---

## Dockerfile

```dockerfile
FROM node:20-bullseye
```

Explanation:

* Specifies the base image for the container.
* `node:20-bullseye` is a Debian-based Node.js image.
* We used this instead of Alpine because SQLite (better-sqlite3) requires glibc, which is not fully supported in Alpine.
* This ensures compatibility and stability.

---

```dockerfile
WORKDIR /app
```

Explanation:

* Sets the working directory inside the container.
* All following commands will execute inside `/app`.
* Keeps container file structure organized.

---

```dockerfile
COPY package*.json ./
```

Explanation:

* Copies `package.json` and `package-lock.json` into the container.
* This allows dependency installation before copying the full source code.
* Improves Docker layer caching.

---

```dockerfile
RUN npm install --production
```

Explanation:

* Installs only production dependencies.
* Excludes development dependencies.
* Reduces image size.
* Prepares the environment for production deployment.

---

```dockerfile
COPY . .
```

Explanation:

* Copies the remaining application source code into the container.
* Includes configuration files, source code, and assets.

---

```dockerfile
RUN npm run build
```

Explanation:

* Builds the Strapi admin panel.
* Prepares static files required for the admin interface.
* Ensures application is production-ready.

---

```dockerfile
EXPOSE 1337
```

Explanation:

* Documents that the container listens on port 1337.
* Strapi runs on port 1337 by default.
* This does not publish the port; it only informs Docker about the expected port.

---

```dockerfile
ENV NODE_ENV=production
```

Explanation:

* Sets the environment to production mode.
* Ensures optimized performance.
* Disables development-specific behavior.

---

```dockerfile
CMD ["npm", "run", "start"]
```

Explanation:

* Defines the default command when the container starts.
* Runs Strapi in production mode.
* This is executed automatically when Docker container runs.

---

# Docker Best Practices Followed

* Used Debian-based image for native module compatibility.
* Installed only production dependencies.
* Built application before runtime.
* Used `.dockerignore` to reduce image size.
* Kept image structure clean and minimal.

---
The image was built locally and pushed to Docker Hub:

```
akash2627/strapi-devops:day4
```

Docker Hub Repository:
[https://hub.docker.com/repository/docker/akash2627/strapi-devops/general](https://hub.docker.com/repository/docker/akash2627/strapi-devops/general)
<img width="1907" height="564" alt="Screenshot 2026-02-12 124326" src="https://github.com/user-attachments/assets/5065733d-7cbd-480f-a7d4-83ed19887f5d" />

---

Very good decision.
Yes — explaining Terraform files line by line in the README makes it much more professional.

We will add a new section before “Deployment Steps”.

You can paste the following into your README.

---

# 6. Terraform Configuration Explanation

This section explains each Terraform file and the purpose of every configuration block used in this project.

---

## provider.tf

```hcl
provider "aws" {
  region = var.aws_region
}
```

Explanation:

* `provider "aws"` tells Terraform that we are using the AWS cloud provider.
* `region = var.aws_region` sets the AWS region dynamically using a variable instead of hardcoding it.
* This allows flexibility to change regions without modifying core configuration.

---

## variables.tf

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}
```

* Defines the AWS region variable.
* Default region is set to ap-south-1.

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

* Defines EC2 instance type.
* Default is t2.micro (Free Tier eligible).

```hcl
variable "key_name" {
  description = "EC2 Key pair name"
  type        = string
}
```

* Stores the EC2 key pair name.
* Required for SSH access.

```hcl
variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "akash2627/strapi-devops:day4"
}
```

* Defines the Docker image that will be pulled inside EC2.
* Makes image configurable without modifying main.tf.

---

## main.tf

### Fetch Latest Ubuntu AMI

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

Explanation:

* `data "aws_ami"` fetches an existing AMI instead of creating one.
* `most_recent = true` ensures latest version is selected.
* `owners` ensures the AMI is from Canonical (official Ubuntu publisher).
* `filter` matches Ubuntu 22.04 images.

---

### Security Group

```hcl
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi access"
```

* Creates a security group.
* Allows network access to EC2.

#### SSH Rule

```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

* Opens port 22 for SSH access.
* Allows inbound traffic from anywhere.

#### Strapi Rule

```hcl
ingress {
  from_port   = 1337
  to_port     = 1337
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

* Opens port 1337.
* Allows public access to Strapi application.

#### Outbound Rule

```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
```

* Allows all outbound traffic.
* Required for pulling Docker image from Docker Hub.

---

### EC2 Instance

```hcl
resource "aws_instance" "strapi_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
```

Explanation:

* Uses Ubuntu AMI fetched earlier.
* Uses variable-defined instance type.
* Uses provided key pair.
* Attaches security group.

---

### user_data

```hcl
user_data = file("${path.module}/user_data.sh")
```

* Passes the user_data.sh script to EC2.
* This script runs automatically during instance launch.

---

### Tags

```hcl
tags = {
  Name = "strapi-terraform-server"
}
```

* Adds a name tag for easier identification in AWS console.

---

## user_data.sh

```bash
#!/bin/bash
apt update -y
apt install -y docker.io
```

* Updates packages.
* Installs Docker.

```bash
systemctl start docker
systemctl enable docker
```

* Starts Docker service.
* Ensures Docker starts automatically on reboot.

```bash
docker pull akash2627/strapi-devops:day4
```

* Pulls Docker image from Docker Hub.

```bash
docker run -d -p 1337:1337 --name strapi-container akash2627/strapi-devops:day4
```

* Runs container in detached mode.
* Maps port 1337 to host.
* Names container for identification.

---

## outputs.tf

```hcl
output "public_ip" {
  value = aws_instance.strapi_server.public_ip
}
```

* Displays EC2 public IP after deployment.
* Used to access Strapi application.

---

---

## 7. Deployment Steps

### Step 1 – Initialize Terraform

```
terraform init
```

### Step 2 – Review Plan

```
terraform plan
```
<img width="1197" height="869" alt="Screenshot 2026-02-12 124224" src="https://github.com/user-attachments/assets/3877620f-cefb-4188-813a-175c587ee119" />


### Step 3 – Apply Infrastructure

```
terraform apply
```
<img width="1004" height="349" alt="Screenshot 2026-02-12 124207" src="https://github.com/user-attachments/assets/bed16553-652d-4a92-a673-e452f414afac" />


After successful deployment, Terraform outputs the public IP address.

Access Strapi using:

```
http://<PUBLIC_IP>:1337
```

<img width="1523" height="983" alt="Screenshot 2026-02-12 124250" src="https://github.com/user-attachments/assets/f0278498-72a1-4535-a845-e70b752abf38" />

---

## 8. Verification

* EC2 instance launched successfully
* Docker installed automatically
* Container pulled from Docker Hub
* Strapi accessible via Public IP
* Admin panel loads successfully

---

## 9. Key Learning Outcomes

* Containerizing a Node.js application using Docker
* Debugging native module issues (Alpine vs Debian images)
* Publishing Docker images to Docker Hub
* Automating EC2 provisioning using Terraform
* Using user_data for application bootstrapping
* Deploying applications without manual server configuration

---

## 10. Conclusion

This project demonstrates a complete automated deployment workflow using Docker and Terraform.

The infrastructure and application setup are fully automated and reproducible. This approach follows DevOps best practices and Infrastructure as Code principles.

---


