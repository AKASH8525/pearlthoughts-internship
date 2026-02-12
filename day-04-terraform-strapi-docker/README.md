
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

The image was built locally and pushed to Docker Hub:

```
akash2627/strapi-devops:day4
```

Docker Hub Repository:
[https://hub.docker.com/repository/docker/akash2627/strapi-devops/general](https://hub.docker.com/repository/docker/akash2627/strapi-devops/general)

---

## 6. Terraform Infrastructure

Terraform was used to provision AWS infrastructure.

### Resources Created

* Security Group

  * Port 22 (SSH)
  * Port 1337 (Strapi)
* EC2 Instance (t2.micro)
* Ubuntu 22.04 AMI (latest)
* user_data automation script

### user_data Automation

When the EC2 instance launches, it automatically:

1. Updates system packages
2. Installs Docker
3. Starts and enables Docker service
4. Pulls the Docker image from Docker Hub
5. Runs the Strapi container on port 1337

No manual SSH configuration was required.

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

### Step 3 – Apply Infrastructure

```
terraform apply
```

After successful deployment, Terraform outputs the public IP address.

Access Strapi using:

```
http://<PUBLIC_IP>:1337
```

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


