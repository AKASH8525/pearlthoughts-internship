
# Task : Dockerized Strapi with PostgreSQL and Nginx Reverse Proxy

## Overview

This task focuses on building a multi-container Dockerized architecture for a Strapi application.

The setup includes:

* A **PostgreSQL** container for persistent data storage
* A **Strapi** container configured to use PostgreSQL
* An **Nginx** container acting as a reverse proxy
* A **user-defined Docker network** to enable container-to-container communication

All services are managed using **Docker Compose**, allowing the entire stack to be deployed with a single command.

The final system allows access to the Strapi Admin Dashboard via:
`http://localhost/admin`

All steps were executed on **Ubuntu 24.04 LTS (WSL2)**.

Perfect 👍 Since you’ve now moved to **Docker Compose**, your README must:

* Explain the **architecture**
* Explain **why Compose**
* Explain the `docker-compose.yml` file **line-by-line**
* Explain how to run it
* Mention improvements over manual setup

---

# Architecture

```
Browser
   ↓
Nginx (Port 80 exposed)
   ↓
Strapi (Internal Port 1337)
   ↓
PostgreSQL (Internal Port 5432)
```

All containers communicate through a shared Docker network defined in Docker Compose.

---

# Project Structure

```
day-02-strapi-postgres-nginx/
│
├── docker-compose.yml
├── strapi-app/
│   ├── Dockerfile
│   ├── .env
│   └── config/database.ts
│
├── nginx/
│   └── nginx.conf
│
└── README.md
```

---

# Docker Compose File Explanation (Line-by-Line)

File: `docker-compose.yml`

---

## Version

```yaml
version: "3.8"
```

Specifies the Docker Compose file format version.

---

## Services Section

```yaml
services:
```

Defines all containers used in this setup.

---

## PostgreSQL Service

```yaml
postgres:
  image: postgres:15
```

Uses the official PostgreSQL version 15 image.

---

```yaml
  container_name: postgres
```

Names the container `postgres`.
This name is used by Strapi to connect to the database.

---

```yaml
  restart: always
```

Automatically restarts the container if it crashes.

---

```yaml
  environment:
    POSTGRES_DB: strapidb
    POSTGRES_USER: strapiuser
    POSTGRES_PASSWORD: strapipassword
```

Sets:

* Database name
* Username
* Password

These must match the `.env` configuration in Strapi.

---

```yaml
  volumes:
    - postgres_data:/var/lib/postgresql/data
```

Creates a named volume to persist database data.
Without this, data would be lost if the container is removed.

---

```yaml
  networks:
    - strapi-net
```

Connects PostgreSQL to the shared Docker network.

---

## Strapi Service

```yaml
strapi:
  build:
    context: ./strapi-app
```

Builds the Strapi image using the Dockerfile inside `strapi-app`.

---

```yaml
  container_name: strapi
```

Names the container `strapi`.

---

```yaml
  restart: always
```

Ensures Strapi restarts automatically if it crashes.

---

```yaml
  env_file:
    - ./strapi-app/.env
```

Loads environment variables from `.env`.

This includes:

* Database host
* Database credentials
* JWT secrets
* App keys

---

```yaml
  depends_on:
    - postgres
```

Ensures PostgreSQL starts before Strapi.

---

```yaml
  networks:
    - strapi-net
```

Connects Strapi to the same Docker network.

---

## Nginx Service

```yaml
nginx:
  image: nginx:alpine
```

Uses lightweight Alpine-based Nginx image.

---

```yaml
  container_name: nginx
```

Names the container `nginx`.

---

```yaml
  restart: always
```

Automatically restarts Nginx if it crashes.

---

```yaml
  ports:
    - "80:80"
```

Maps:

* Host port 80
* To container port 80

This allows access via `http://localhost`.

---

```yaml
  volumes:
    - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
```

Mounts custom Nginx configuration file into the container.

`ro` means read-only.

---

```yaml
  depends_on:
    - strapi
```

Ensures Strapi starts before Nginx.

---

```yaml
  networks:
    - strapi-net
```

Connects Nginx to the shared Docker network.

---

## Volumes Section

```yaml
volumes:
  postgres_data:
```

Defines a named volume for PostgreSQL data persistence.

---

## Networks Section

```yaml
networks:
  strapi-net:
    driver: bridge
```

Defines a user-defined bridge network for container communication.

Docker automatically provides internal DNS resolution on this network.

---

# Dockerfile Explanation (Strapi)

File: `strapi-app/Dockerfile`

---

```dockerfile
FROM node:20-alpine
```

Uses Node.js 20 (required by Strapi v5).

---

```dockerfile
WORKDIR /app
```

Sets working directory inside container.

---

```dockerfile
COPY package.json package-lock.json* ./
```

Copies dependency files first for caching.

---

```dockerfile
RUN npm install
```

Installs dependencies inside container.

---

```dockerfile
COPY . .
```

Copies application source code.

---

```dockerfile
RUN npm run build
```

Builds Strapi admin panel.

---

```dockerfile
EXPOSE 1337
```

Documents internal Strapi port.

---

```
CMD ["npm", "run", "start"]
```

Starts Strapi server.

---

# How to Run the Application

## Step 1 – Navigate to Project Root

```
cd day-02-strapi-postgres-nginx
```

---

## Step 2 – Build and Start All Services

```
docker compose up -d --build
```

This will:

* Build Strapi image
* Create network
* Create volume
* Start PostgreSQL
* Start Strapi
* Start Nginx

---

## Step 3 – Verify Running Containers

```
docker compose ps
```

---

## Step 4 – Access Application

Open:

```
http://localhost/admin
```

---

# Stop the Application

```
docker compose down
```

---

# Improvements Over Manual Docker Setup

* Centralized service definition
* Single command deployment
* Automatic network creation
* Persistent database storage
* Restart policies
* Cleaner and scalable architecture

---



## Final Verification

To ensure all requirements are met, perform the following checks:

1. **Check Network:**
```bash
docker network inspect strapi-net

```


* *Expected Result:* All three containers (`postgres`, `strapi`, `nginx`) should be listed under the "Containers" section.
<img width="816" height="741" alt="Screenshot 2026-02-10 115417" src="https://github.com/user-attachments/assets/6add4f24-6839-42b6-822a-693a269ca4fc" />


2. **Access Application:**
Open a web browser and navigate to:
`http://localhost/admin`
* *Expected Result:* The Strapi login page loads via Nginx on port 80.
<img width="1886" height="738" alt="Screenshot 2026-02-10 115526" src="https://github.com/user-attachments/assets/60d30195-824d-4b01-9268-6c81cabdde79" />



## Conclusion

This implementation fulfills all task requirements:

* **Network:** `strapi-net` created and used.
* **Database:** PostgreSQL configured with secure credentials.
* **Connectivity:** Strapi connects to PostgreSQL via environment variables.
* **Proxy:** Nginx maps host port 80 to Strapi's internal port 1337.
* **Isolation:** All components run exclusively on the user-defined network.


BRANCH:akash-k-task
