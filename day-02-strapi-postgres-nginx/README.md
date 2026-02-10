
# Task : Dockerized Strapi with PostgreSQL and Nginx Reverse Proxy

## Overview

This task focuses on building a multi-container Dockerized architecture for a Strapi application.

The setup includes:

* A **PostgreSQL** container for persistent data storage
* A **Strapi** container configured to use PostgreSQL
* An **Nginx** container acting as a reverse proxy
* A **user-defined Docker network** to enable container-to-container communication

The final system allows access to the Strapi Admin Dashboard via:
`http://localhost/admin`

All steps were executed on **Ubuntu 24.04 LTS (WSL2)**.

## Architecture Overview

```text
Client (Browser)
      |
      |  http://localhost (port 80)
      v
   Nginx (Reverse Proxy)
      |
      |  http://strapi:1337
      v
   Strapi Application
      |
      |  PostgreSQL protocol
      v
   PostgreSQL Database

```

All containers run on a single user-defined Docker network named `strapi-net`.

## Approach

The task was approached in a layered and incremental manner to ensure stability and easy debugging:

1. **Networking first** – create a user-defined Docker network
2. **Database layer** – run PostgreSQL with proper credentials
3. **Application layer** – configure Strapi to use PostgreSQL
4. **Reverse proxy layer** – expose Strapi using Nginx
5. **Verification** – confirm end-to-end access via browser

This approach mirrors real-world DevOps practices, where each layer is validated before moving to the next.

---

## Environment Details

* **OS:** Ubuntu 24.04 LTS (WSL2)
* **Docker Engine:** Docker Desktop with WSL2 integration
* **Images:** `postgres:15`, `node:20-alpine`, `nginx:alpine`

## Folder Structure

```text
day-02-strapi-postgres-nginx/
├── strapi-app/
│   ├── Dockerfile             # Strapi image definition
│   ├── .env                   # Environment variables
│   ├── config/database.ts     # Database connection logic
│   └── [Source Code]          # Strapi application source
├── nginx/
│   └── nginx.conf             # Nginx proxy configuration
└── README.md                  # Documentation

```

---

## Step 1: Create User-Defined Network

To fulfill the requirement of isolated container communication, we create a specific bridge network.

**Command:**

```bash
docker network create strapi-net

```

**Explanation:**

* `docker network create`: Initializes a new network driver.
* `strapi-net`: **(Requirement)** The specific name assigned to this network. All subsequent containers must attach to this network to resolve each other by name.

**Verification:**

```bash
docker network ls

```

* *Success Criterion:* `strapi-net` appears in the driver list.
<img width="431" height="149" alt="Screenshot 2026-02-10 115326" src="https://github.com/user-attachments/assets/924f3f6f-16b1-4362-84e0-3a2128d82976" />

---

## Step 2: PostgreSQL Container Setup

We deploy the database with the required environment variables for authentication.

**Command:**

```bash
docker run -d --name postgres --network strapi-net \
  -e POSTGRES_DB=strapidb \
  -e POSTGRES_USER=strapiuser \
  -e POSTGRES_PASSWORD=strapipassword \
  postgres:15

```

**Line-by-Line Explanation:**

* `docker run -d`: Starts the container in detached mode (background).
* `--name postgres`: Assigns the hostname `postgres`. This is crucial for the Strapi container to locate the database.
* `--network strapi-net`: **(Requirement)** Attaches the database to the user-defined network.
* `-e POSTGRES_DB=strapidb`: **(Requirement)** Sets the default database name.
* `-e POSTGRES_USER=strapiuser`: **(Requirement)** Sets the database username.
* `-e POSTGRES_PASSWORD=strapipassword`: **(Requirement)** Sets the database password.
* `postgres:15`: Uses the stable PostgreSQL version 15 image.

---

## Step 3: Strapi Application Setup

### 3.1 Dockerfile Configuration (`strapi-app/Dockerfile`)

This file defines the build process for the Strapi application.

```dockerfile
FROM node:20-alpine
# Uses a lightweight Node.js 20 image based on Alpine Linux.

WORKDIR /app
# Sets the working directory inside the container to /app.

COPY package.json package-lock.json* ./
# Copies dependency manifests first to leverage Docker layer caching.

RUN npm install
# Installs all project dependencies defined in package.json.

COPY . .
# Copies the rest of the application source code into the container.

RUN npm run build
# Compiles the Strapi Admin Panel for production use.

EXPOSE 1337
# Documents that the container listens on port 1337 internally.

CMD ["npm", "run", "start"]
# Specifies the command to start the application when the container launches.

```

### 3.2 Database Connection (`strapi-app/config/database.ts`)

This configuration ensures Strapi connects using the variables defined in the requirements.

```typescript
export default ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', 'postgres'), // Connects to 'postgres' container
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', 'strapidb'),
      user: env('DATABASE_USERNAME', 'strapiuser'),
      password: env('DATABASE_PASSWORD', 'strapipassword'),
      ssl: env.bool('DATABASE_SSL', false),
    },
  },
});

```

### 3.3 Build and Run Strapi

**Build Command:**

```bash
cd strapi-app
docker build -t strapi-postgres .

```

**Run Command:**

```bash
docker run -d --name strapi --network strapi-net --env-file .env strapi-postgres

```

**Explanation:**

* `--name strapi`: key identifier used by Nginx.
* `--network strapi-net`: **(Requirement)** Ensures Strapi is on the same network as PostgreSQL.
* `--env-file .env`: Injects the `DATABASE_HOST`, `USER`, and `PASSWORD` variables into the container.

---

## Step 4: Nginx Reverse Proxy Setup

### 4.1 Nginx Configuration (`nginx/nginx.conf`)

This file configures the proxy to route traffic from localhost to the Strapi container.

```nginx
events {} 
# Basic event processing block required by Nginx.

http {
    server {
        listen 80; 
        # Nginx listens for HTTP traffic on port 80 inside the container.

        location / {
            proxy_pass http://strapi:1337; 
            # (Requirement) Proxies requests to the 'strapi' container on port 1337.
            
            proxy_set_header Host $host; 
            # Forwards the original host header to the Strapi application.
        }
    }
}

```

### 4.2 Run Nginx Container

**Command:**

```bash
docker run -d --name nginx --network strapi-net -p 80:80 \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:alpine

```

**Line-by-Line Explanation:**

* `--name nginx`: Names the container `nginx`.
* `--network strapi-net`: **(Requirement)** Connects Nginx to the same network as Strapi and Postgres.
* `-p 80:80`: **(Requirement)** Maps port 80 on the host machine to port 80 in the container.
* `-v ...:/etc/nginx/nginx.conf:ro`: Mounts the custom configuration file into the container as read-only.

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
