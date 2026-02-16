# 1. Task Title

**Automated Strapi Deployment using GitHub Actions and Terraform on AWS**

---

## 2. Project Overview

This project implements a complete CI/CD pipeline to automate the deployment of a Strapi application using GitHub Actions and Terraform on AWS.

The objective of this project is to:

- Automatically build a Docker image of the Strapi application on every push to the main branch.
- Push the built image to a private Amazon Elastic Container Registry (ECR).
- Manually trigger a Terraform-based deployment workflow.
- Provision and update infrastructure on AWS.
- Automatically deploy and run the updated Docker image on an EC2 instance.

This setup ensures a structured, repeatable, and automated deployment process using Infrastructure as Code principles.

---

## 3. Architecture Overview

The deployment architecture follows a structured CI/CD workflow:

1. Developer pushes code to the main branch.
2. GitHub Actions CI workflow is triggered.
3. The Docker image is built and tagged using the commit SHA.
4. The image is pushed to a private Amazon ECR repository.
5. A manual CD workflow is triggered using workflow_dispatch.
6. Terraform initializes using an S3 remote backend.
7. Terraform updates the EC2 instance configuration with the new image tag.
8. The EC2 instance pulls the updated image from ECR.
9. Docker restarts the Strapi container with the new version.

### Deployment Flow

Push to main  
→ CI builds Docker image  
→ Image pushed to Amazon ECR  
→ Manual CD trigger  
→ Terraform apply  
→ EC2 pulls updated image  
→ Docker container restarts  
→ Strapi application becomes available via public IP

---

## 4. Technology Stack

The following technologies and services are used in this project:

### GitHub Actions

Used to implement Continuous Integration (CI) and Continuous Deployment (CD) workflows.

### Docker

Used to containerize the Strapi application and ensure consistent runtime behavior across environments.

### Terraform

Used as Infrastructure as Code (IaC) to provision and manage AWS resources.

### Amazon EC2

Hosts the Strapi Docker container.

### Amazon ECR

Stores private Docker images built by the CI pipeline.

### Amazon S3

Used as a remote backend for Terraform state management.

### AWS IAM

Used to assign an IAM instance profile to EC2, allowing secure access to ECR without hardcoded credentials.

### Ubuntu 22.04 (EC2)

Base operating system for the EC2 instance.

---

## 5. Repository Structure

The repository is organized to clearly separate application code, infrastructure code, and CI/CD workflows.

```
pearlthoughts-internship/
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── terraform.yml
│
├── day-04-terraform-strapi-docker/
│   ├── strapi-app/
│   │   ├── Dockerfile
│   │   ├── package.json
│   │   └── application source code
│   │
│   └── terraform-day5/
│       ├── main.tf
│       ├── provider.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── terraform.tfvars
│       └── modules/
│           ├── ec2/
│           ├── ecr/
│           └── security-group/
│
└── README.md

```

### Folder Responsibilities

**.github/workflows/**

* Contains CI and CD workflow definitions.
* `ci.yml` handles Docker image build and push.
* `terraform.yml` handles infrastructure deployment.

**strapi-app/**

* Contains the Strapi application source code.
* Includes Dockerfile used to build the container image.

**terraform-day5/**

* Contains Terraform configuration for infrastructure provisioning.
* Uses a modular structure for better maintainability and scalability.

**modules/**

* `ec2/` – Provisions EC2 instance and handles Docker deployment using user_data.
* `ecr/` – Creates and manages the Amazon ECR repository.
* `security-group/` – Defines inbound and outbound traffic rules.

This structure ensures separation of concerns between application code, infrastructure code, and automation workflows.

---

## 6. Infrastructure Design

The infrastructure is provisioned using Terraform following a modular and production-oriented design.

### 6.1 Modular Architecture

The Terraform configuration is divided into reusable modules:

**Security Group Module**
* Creates a security group allowing:
* Port 22 (SSH)
* Port 1337 (Strapi application)
* Enables controlled network access.


**ECR Module**
* Creates a private Amazon ECR repository.
* Enables image scanning on push.
* Stores Docker images built by the CI pipeline.


**EC2 Module**
* Launches an Ubuntu EC2 instance.
* Attaches an IAM instance profile (`ec2-ecr-role`) to allow secure ECR access.
* Uses user_data to:
* Install Docker and AWS CLI.
* Authenticate with ECR.
* Pull the specified Docker image.
* Run the Strapi container with required environment variables.
This modular approach improves clarity, reusability, and maintainability.

---

### 6.2 Remote Backend Configuration

Terraform uses an Amazon S3 bucket as a remote backend for storing state files.

Benefits of using a remote backend:

* Prevents state conflicts.
* Enables consistent infrastructure tracking across CI/CD runs.
* Ensures state persistence between local and GitHub Actions environments.
* Avoids accidental infrastructure recreation.

---

### 6.3 EC2 Deployment Strategy

The EC2 instance is designed to:

* Automatically install Docker during boot.
* Authenticate with Amazon ECR using IAM role permissions.
* Pull a Docker image tagged with the commit SHA.
* Restart the container when a new image tag is deployed.

When the `image_tag` variable changes:

* Terraform detects configuration changes.
* The EC2 instance updates.
* The new Docker image is pulled.
* The Strapi container is restarted with the updated version.

This ensures controlled and versioned deployments.

---

### 6.4 Image Versioning Strategy

Each Docker image is tagged using the Git commit SHA.

Advantages:

* Clear traceability between source code and deployed version.
* No ambiguity in image versions.
* Supports rollback if necessary.

---

## 7. Continuous Integration (CI) Workflow

The CI workflow is defined in:

`.github/workflows/ci.yml`

Its responsibility is to automatically build and push the Docker image of the Strapi application to Amazon ECR whenever code is pushed to the main branch.

---

### 7.1 Workflow Trigger

```yaml
name: CI - Build & Push Strapi Image

on:
  push:
    branches:
      - main

```

**Explanation:**

* `name` defines the workflow name displayed in GitHub Actions.
* `on: push` specifies that the workflow runs automatically on code push.
* `branches: - main` ensures the workflow only triggers when changes are pushed to the main branch.

This enforces a controlled CI process tied to the production branch.

---

### 7.2 Global Environment Variables

```yaml
env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: strapi-devops

```

**Explanation:**

* `AWS_REGION` defines the AWS region where infrastructure is deployed.
* `ECR_REPOSITORY` specifies the target ECR repository name.

Using global environment variables improves readability and prevents hardcoding values in multiple steps.

---

### 7.3 Job Definition

```yaml
jobs:
  build:
    runs-on: ubuntu-latest

```

**Explanation:**

* `jobs` defines workflow execution units.
* `build` is the job name.
* `runs-on: ubuntu-latest` specifies that GitHub provides a Linux runner for executing the workflow.

The entire CI pipeline runs inside a temporary Ubuntu environment.

---

### 7.4 Exporting Image Tag as Output

```yaml
    outputs:
      image_tag: ${{ steps.vars.outputs.tag }}

```

**Explanation:**

* Defines an output variable from this job.
* The value is taken from a later step (`vars` step).
* This output can be consumed by other workflows if needed.

The image tag represents the Git commit SHA.

---

### 7.5 Checkout Repository Code

```yaml
      - name: Checkout Code
        uses: actions/checkout@v4

```

**Explanation:**

* Downloads the repository source code into the runner.
* Required before building the Docker image.

Without this step, Docker cannot access the application source.

---

### 7.6 Generate Docker Image Tag

```yaml
      - name: Set Image Tag
        id: vars
        run: echo "tag=${GITHUB_SHA}" >> $GITHUB_OUTPUT

```

**Explanation:**

* `GITHUB_SHA` is an automatic GitHub variable representing the commit hash.
* The commit SHA is used as the Docker image tag.
* The tag is written to `$GITHUB_OUTPUT`.
* `id: vars` allows referencing this output later.

This ensures each Docker image version is uniquely traceable to a commit.

---

### 7.7 Configure AWS Credentials

```yaml
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

```

**Explanation:**

* Uses official AWS GitHub Action.
* Reads credentials from GitHub Secrets.
* Authenticates the runner with AWS.
* Grants permission to interact with ECR.

This avoids hardcoding credentials in the repository.

---

### 7.8 Login to Amazon ECR

```yaml
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

```

**Explanation:**

* Logs Docker into Amazon ECR.
* Uses AWS credentials configured earlier.
* Outputs the ECR registry URI automatically.
* Eliminates manual registry URL construction errors.

This step enables Docker push operations to ECR.

---

### 7.9 Build and Push Docker Image

```yaml
      - name: Build and Push Docker Image
        run: |
          IMAGE_URI=${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ steps.vars.outputs.tag }}

          docker build -t $IMAGE_URI ./day-04-terraform-strapi-docker/strapi-app
          docker push $IMAGE_URI

```

**Explanation:**

1. Construct full image URI:
```
<account-id>.dkr.ecr.<region>.amazonaws.com/strapi-devops:<commit-sha>

```


2. `docker build`
* Builds image from the `strapi-app` directory.
* Tags it with commit SHA.


3. `docker push`
* Pushes image to private ECR repository.



This completes the CI process.

---

### 7.10 CI Workflow Summary

The CI workflow performs the following:

1. Detects push to main branch.
2. Checks out repository.
3. Generates unique image tag (commit SHA).
4. Authenticates with AWS.
5. Logs into ECR.
6. Builds Docker image.
7. Pushes image to ECR.
8. Exposes image_tag as workflow output.

This ensures:

* Every commit results in a uniquely versioned Docker image.
* Image traceability between source code and deployment.
* Automated container build process.

---

## 8. Continuous Deployment (CD) Workflow

The CD workflow is defined in:

`.github/workflows/terraform.yml`

Its responsibility is to deploy a selected Docker image version to the EC2 instance using Terraform.

Unlike CI, this workflow is manually triggered to ensure controlled production deployments.

---

### 8.1 Workflow Trigger (Manual Deployment)

```yaml
name: CD - Deploy with Terraform

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Docker image tag to deploy"
        required: true

```

**Explanation:**

* `name` defines how the workflow appears in GitHub Actions.
* `workflow_dispatch` enables manual execution.
* `inputs.image_tag` allows the user to specify which Docker image tag should be deployed.
* `required: true` ensures a deployment cannot start without specifying a version.

This provides version-controlled and approval-based deployment.

---

### 8.2 Global Environment Variables

```yaml
env:
  AWS_REGION: us-east-1

```

**Explanation:**

* Defines AWS region used during deployment.
* Ensures consistent region configuration across all Terraform commands.

---

### 8.3 Job Definition

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest

```

**Explanation:**

* Defines a job named `deploy`.
* Runs on a GitHub-hosted Ubuntu runner.
* This runner executes Terraform commands.

---

### 8.4 Checkout Repository Code

```yaml
      - name: Checkout Code
        uses: actions/checkout@v4

```

**Explanation:**

* Pulls the latest repository code into the runner.
* Required for accessing Terraform configuration files.

---

### 8.5 Configure AWS Credentials

```yaml
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

```

**Explanation:**

* Authenticates GitHub runner with AWS.
* Credentials are securely stored in GitHub Secrets.
* Grants Terraform permission to manage AWS resources.

This avoids exposing credentials in code.

---

### 8.6 Setup Terraform

```yaml
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

```

**Explanation:**

* Installs Terraform in the GitHub runner.
* Ensures consistent Terraform version during deployment.

---

### 8.7 Terraform Initialization

```yaml
      - name: Terraform Init
        working-directory: day-04-terraform-strapi-docker/terraform-day5
        run: terraform init

```

**Explanation:**

* Initializes Terraform in the specified directory.
* Downloads required providers.
* Connects to the S3 remote backend.
* Loads existing infrastructure state.

This ensures Terraform operates on existing infrastructure rather than creating new resources unintentionally.

---

### 8.8 Terraform Plan

```yaml
      - name: Terraform Plan
        working-directory: day-04-terraform-strapi-docker/terraform-day5
        run: |
          terraform plan \
          -var="project_name=strapi-devops" \
          -var="image_tag=${{ github.event.inputs.image_tag }}" \
          -var="key_name=Akash-PT"

```

**Explanation:**

* Executes Terraform plan with variables:
* `project_name`
* `image_tag` (from manual input)
* `key_name`


* Compares current infrastructure state with desired configuration.
* Detects changes such as updated Docker image tag.

This step previews infrastructure changes before applying them.

---

### 8.9 Terraform Apply

```yaml
      - name: Terraform Apply
        working-directory: day-04-terraform-strapi-docker/terraform-day5
        run: |
          terraform apply -auto-approve \
          -var="project_name=strapi-devops" \
          -var="image_tag=${{ github.event.inputs.image_tag }}" \
          -var="key_name=Akash-PT"

```

**Explanation:**

* Applies infrastructure changes automatically.
* Uses `-auto-approve` to skip manual confirmation.
* Passes the selected `image_tag` variable.
* Updates EC2 configuration.

When `image_tag` changes:

* Terraform updates the EC2 user_data configuration.
* The instance restarts.
* Docker pulls the new image from ECR.
* Existing container is stopped.
* New container is started with updated version.

---

### 8.10 CD Workflow Summary

The CD workflow performs the following:

1. Manually triggered deployment.
2. Accepts image version as input.
3. Authenticates with AWS.
4. Initializes Terraform with remote backend.
5. Plans infrastructure changes.
6. Applies updates to EC2.
7. Automatically redeploys the selected Docker image.

This approach ensures:

* Controlled production deployments.
* Version-specific releases.
* Infrastructure managed entirely as code.
* Full traceability between Git commit and running application version.


---

## 9. Deployment Workflow

This section describes the complete end-to-end flow from code change to live application deployment.

The workflow is divided into two phases:

* Continuous Integration (CI)
* Continuous Deployment (CD)

---

### 9.1 Development Phase

1. Developer makes changes to the Strapi application.
2. Changes are committed and pushed to the `main` branch.
3. GitHub automatically triggers the CI workflow.

---

### 9.2 Continuous Integration Phase

Once code is pushed:

1. GitHub Actions runner checks out the repository.
2. A Docker image tag is generated using the Git commit SHA.
3. The runner authenticates with AWS using GitHub Secrets.
4. The Docker image is built from the `strapi-app` directory.
5. The image is tagged using:
`<account-id>.dkr.ecr.<region>.amazonaws.com/strapi-devops:<commit-sha>`
6. The image is pushed to the private Amazon ECR repository.
7. The CI job completes successfully, and the image becomes available for deployment.

At this stage:

* No infrastructure changes occur.
* The new image version is stored securely in ECR.
* The commit SHA uniquely identifies the image version.

---

### 9.3 Continuous Deployment Phase

Deployment is intentionally manual for controlled releases.

1. The user navigates to GitHub Actions.
2. Selects the "CD - Deploy with Terraform" workflow.
3. Clicks "Run workflow".
4. Provides the image_tag (commit SHA from CI).

Once triggered:

1. The GitHub runner authenticates with AWS.
2. Terraform initializes using the S3 remote backend.
3. Terraform compares the current infrastructure state with the desired configuration.
4. If the image_tag has changed, Terraform updates the EC2 configuration.
5. The EC2 instance executes updated user_data.
6. The instance:
* Logs in to Amazon ECR
* Pulls the new Docker image
* Stops the existing Strapi container
* Starts a new container with the updated image



---

### 9.4 Application Availability

After Terraform apply completes:

1. The EC2 instance outputs the public IP.
2. The Strapi application becomes available at:
`http://<public-ip>:1337`
3. The deployed version corresponds exactly to the commit SHA selected during deployment.

---

### 9.5 Version Traceability

This workflow guarantees:

* Each deployment corresponds to a specific Git commit.
* Docker images are versioned using commit SHA.
* Infrastructure changes are fully managed by Terraform.
* No manual Docker commands are required after CD is properly configured.

This ensures a reliable, repeatable, and auditable deployment process.

---

## 10. Runtime Configuration and Environment Variables

The Strapi application requires several runtime environment variables to function correctly in production mode.

These variables are injected during container startup using Docker `-e` flags inside the EC2 user_data script.

### 10.1 Required Environment Variables

The following environment variables are configured:

* `APP_KEYS`
* `ADMIN_JWT_SECRET`
* `JWT_SECRET`
* `API_TOKEN_SALT`
* `NODE_ENV=production`

These variables are mandatory for Strapi v4 to:

* Secure admin authentication
* Generate and validate JWT tokens
* Manage API tokens
* Operate in production mode

---

### 10.2 How Variables Are Injected

During Terraform deployment:

1. The EC2 instance runs a user_data script.
2. The script installs Docker and AWS CLI.
3. The instance authenticates with Amazon ECR.
4. The Docker image is pulled using the specified image_tag.
5. The container is started with required environment variables.

Example Docker run command:

```bash
docker run -d -p 1337:1337 --name strapi --restart unless-stopped \
-e APP_KEYS="..." \
-e ADMIN_JWT_SECRET="..." \
-e JWT_SECRET="..." \
-e API_TOKEN_SALT="..." \
-e NODE_ENV=production \
<image-uri>

```

---

### 10.3 Why Environment Variables Are Required

Strapi does not allow startup without these secrets because:

* JWT signing requires secure keys.
* Admin authentication must be protected.
* API token generation requires a salt value.

Without these variables, Strapi fails at runtime with configuration errors.

---

### 10.4 Version-Based Deployment

The Docker image version is passed as:

`-var="image_tag=<commit-sha>"`

When this value changes:

* Terraform updates EC2 configuration.
* The instance pulls the new image.
* The container restarts with updated code.

---

### 10.3 Why Environment Variables Are Required

Strapi does not allow startup without these secrets because:

* JWT signing requires secure keys.
* Admin authentication must be protected.
* API token generation requires a salt value.

Without these variables, Strapi fails at runtime with configuration errors.

---

### 10.4 Version-Based Deployment

The Docker image version is passed as:

`-var="image_tag=<commit-sha>"`

When this value changes:

* Terraform updates EC2 configuration.
* The instance pulls the new image.
* The container restarts with updated code.

## 11. Security Considerations

This project follows multiple security best practices to protect infrastructure and credentials.

### 11.1 No Hardcoded AWS Credentials

AWS credentials are stored securely in GitHub Secrets:

* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`
* `AWS_ACCOUNT_ID`

They are never committed to the repository.

---

### 11.2 IAM Role for EC2

The EC2 instance uses an IAM instance profile:

`ec2-ecr-role`

This allows:

* Secure authentication with Amazon ECR.
* Pulling Docker images without embedding AWS keys in the instance.

This follows the principle of least privilege.

---

### 11.3 Private Container Registry

Docker images are stored in:

**Amazon Elastic Container Registry (ECR)**

The repository is private, ensuring:

* Images are not publicly accessible.
* Controlled access through IAM permissions.

---

### 11.4 Remote Terraform Backend

Terraform state is stored in Amazon S3.

Benefits:

* Prevents local state conflicts.
* Protects infrastructure state from accidental deletion.
* Enables consistent infrastructure tracking across environments.

---

### 11.5 Controlled Deployment

Continuous Deployment is manual (`workflow_dispatch`).

This ensures:

* No accidental production deployment.
* Controlled release management.
* Explicit version selection during deployment.

---

## 12. Verification and Testing Steps

After deployment, the following steps can be used to verify successful execution.

### 12.1 Verify CI Success

1. Navigate to GitHub Actions.
2. Open the CI workflow run.
3. Confirm:
* Docker build completed successfully.
* Image pushed to ECR.


4. Verify image exists in Amazon ECR console.

---

### 12.2 Verify CD Success

1. Trigger the CD workflow manually.
2. Provide the desired `image_tag`.
3. Confirm:
* `terraform init` completed.
* `terraform plan` detected changes.
* `terraform apply` completed successfully.


4. Note the output `public_ip`.

---

### 12.3 Verify EC2 Deployment

SSH into the EC2 instance:

```bash
ssh -i <key.pem> ubuntu@<public-ip>

```

Check running containers:

```bash
sudo docker ps

```

Confirm that:

* The container is running.
* The image tag matches the selected commit SHA.

---

### 12.4 Verify Application Availability

Open a browser and navigate to:

```
http://<public-ip>:1337

```

If deployment is successful, the Strapi application will load without errors.

---

### 12.5 Troubleshooting Checklist

If the application is not accessible:

* Confirm port 1337 is open in the security group.
* Check Docker container status.
* Review container logs:

```bash
sudo docker logs strapi

```

* Confirm ECR login succeeded in `user_data`.
* Ensure environment variables are correctly passed.

---

## 13. Key Learnings

This project provided practical experience in designing and implementing a production-style CI/CD pipeline using modern DevOps tools.

### 13.1 CI/CD Pipeline Design

* Separation of CI and CD responsibilities.
* Automated image build on push.
* Controlled manual production deployment.
* Version-based deployment using commit SHA.

---

### 13.2 Docker Image Versioning

* Tagging Docker images using Git commit SHA ensures traceability.
* Each deployed version directly maps to source code.
* Enables rollback capability if needed.

---

### 13.3 Infrastructure as Code (Terraform)

* Modular Terraform structure improves maintainability.
* Remote backend prevents state conflicts.
* Infrastructure changes are predictable and version-controlled.
* Deployment logic fully automated via Terraform variables.

---

### 13.4 AWS Service Integration

* Secure authentication with AWS using GitHub Secrets.
* IAM instance profile eliminates need for hardcoded credentials.
* Private ECR used as a secure container registry.
* EC2 `user_data` used for bootstrapping Docker environment.

---

### 13.5 Runtime Configuration Management

* Understanding of environment-based configuration.
* Proper handling of required secrets for Strapi.
* Importance of runtime variables in containerized applications.

---

### 13.6 Debugging and Operational Awareness

During implementation, multiple real-world issues were encountered and resolved:

* ECR authentication errors
* Terraform backend configuration issues
* EC2 public IP changes
* Docker container startup failures
* Missing runtime environment variables

This improved troubleshooting skills and understanding of end-to-end deployment systems.

---
