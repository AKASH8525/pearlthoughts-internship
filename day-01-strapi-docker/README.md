---
Day 01 – Running and Dockerizing a Strapi Application Locally

## Overview

This task focuses on setting up a **Strapi application locally** and then **containerizing it using Docker**.
The objective is to understand how Strapi works in a normal local environment and how the same application can be packaged and run consistently using Docker.

All steps were performed on **Ubuntu 24.04.1 LTS (WSL2)**.

---

## Environment Details

* Operating System: Ubuntu 24.04.1 LTS (via WSL2 on Windows)
* Node.js: v20.x (installed using NVM)
* npm: v10.x
* Strapi: v5
* Docker: Docker Desktop with WSL2 integration

---

## Step 1: Installing Node.js (Required for Strapi)

Strapi v5 requires **Node.js version 20 or above**.
To manage Node versions cleanly, **NVM (Node Version Manager)** was used.

### Install NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
```

### Install and use Node.js 20

```bash
nvm install 20
nvm use 20
```

### Verify installation

```bash
node -v
npm -v
```

Expected output:

* Node.js version should be `v20.x.x`
* npm version should be `10.x` or higher

---

## Step 2: Creating the Strapi Application Locally

A dedicated folder structure was created to maintain all internship tasks in a single repository.

### Directory structure

```text
pearlthoughts-internship/
└── day-01-strapi-docker/
    └── strapi-app/
```

### Create Strapi application

```bash
npx create-strapi-app@latest strapi-app --quickstart
```

Explanation:

* `npx` runs the latest Strapi project generator
* `--quickstart` sets up Strapi with SQLite for local development
* Strapi automatically installs dependencies and starts the server

### Access Strapi

* Application URL: [http://localhost:1337](http://localhost:1337)
* Admin Panel: [http://localhost:1337/admin](http://localhost:1337/admin)

An administrator account was created through the admin panel to confirm the application was working correctly.

After verification, Strapi was stopped:

```bash
Ctrl + C
```

---

## Step 3: Dockerizing the Strapi Application

### 3.1 Dockerfile Creation

The `Dockerfile` was created inside the `strapi-app` directory.

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "start"]
```

Explanation:

* `node:20-alpine` ensures compatibility with Strapi v5
* Dependencies are copied and installed separately to leverage Docker caching
* Admin panel is built during image creation
* Port `1337` is exposed for Strapi access
* Application starts using `npm run start`

---

### 3.2 .dockerignore File

A `.dockerignore` file was added to keep the image clean and secure.

```dockerignore
node_modules
.cache
build
.env
.git
.gitignore
README.md
```

Explanation:

* Prevents unnecessary files from being copied into the Docker image
* Ensures sensitive files like `.env` are not baked into the image

---

## Step 4: Environment Variables Handling

Strapi generates a `.env` file during local setup containing required secrets such as:

* `ADMIN_JWT_SECRET`
* `JWT_SECRET`
* `APP_KEYS`

For security reasons:

* The `.env` file is **not included in the Docker image**
* Environment variables are injected at runtime using `--env-file`

This follows Docker best practices.

---

## Step 5: Building the Docker Image

```bash
docker build -t strapi-day01 .
```

Explanation:

* Builds a Docker image named `strapi-day01`
* Includes Strapi application and all required dependencies

---

## Step 6: Running Strapi in Docker

```bash
docker run -d --env-file .env -p 1337:1337 --name strapi-day01-container strapi-day01
```

Explanation:

* `-d` runs the container in detached mode
* `--env-file .env` injects required environment variables at runtime
* `-p 1337:1337` maps container port to local machine
* `--name` assigns a readable container name

### Verify container status

```bash
docker ps
```
<img width="1448" height="105" alt="image" src="https://github.com/user-attachments/assets/069a4d20-8704-43af-9ef8-782e5000e867" />

<img width="1070" height="581" alt="image" src="https://github.com/user-attachments/assets/57c39f72-d6e5-439f-ba50-cfe2ef0a81fd" />

---

## Step 7: Accessing the Application

Once the container is running:

* Strapi URL: [http://localhost:1337](http://localhost:1337)
* Admin Panel: [http://localhost:1337/admin](http://localhost:1337/admin)

The admin panel loads successfully, confirming that Strapi is running inside Docker.

<img width="1867" height="628" alt="image" src="https://github.com/user-attachments/assets/cfe2fe1d-5c26-44c2-8375-e7a951e4076c" />

---

## Output Verification

Docker container status:

```text
STATUS: Up
PORTS: 0.0.0.0:1337->1337/tcp
```

Strapi logs confirm successful startup:

```text
Strapi started successfully
```

---

## Summary

In this task:

* Strapi was installed and verified locally
* A Dockerfile was created to containerize the application
* Environment variables were handled securely using runtime injection
* The Strapi application was successfully run inside a Docker container

This completes **Day-01: Running and Dockerizing Strapi Locally**.

---
