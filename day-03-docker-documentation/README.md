# 1. What is Docker?

## What is Docker?

* Docker is a tool used to **create, run, and manage containers**.

* A container is a small package that contains:

  * Application code
  * Runtime (Node, Python, Java, etc.)
  * Libraries
  * Dependencies
  * Required system tools

* A container runs the same everywhere:

  * Developer laptop
  * Testing server
  * Production server

---

## What is a Container?

* A container is a **lightweight isolated environment**.
* It shares the host operating system kernel.
* It does NOT include a full OS like a Virtual Machine.
* It starts very fast.
* It uses less memory.

---

# Why Docker?

## Problem Before Docker

* Application works in developer system
* Fails in server
* Different:

  * OS versions
  * Node/Python versions
  * Library versions
  * Environment settings

Common issue:
"It works on my machine"

---

## Problems Without Docker

* Manual installation of dependencies
* Version conflicts
* Hard to replicate environment
* Difficult scaling
* Slow deployment
* Resource waste

---

# Problem Docker Solves

## 1. Environment Consistency

* Same image
* Same dependencies
* Same runtime
* Same behavior everywhere

---

## 2. Isolation

* Each app runs separately
* No dependency conflict
* Clean separation

---

## 3. Lightweight Deployment

* No full OS required
* Faster startup
* Lower memory usage

---

## 4. Easy Scaling

* Run multiple containers quickly
* Good for microservices

---

## 5. Easy Sharing

* Share Docker image
* Anyone can run using one command

Example:

```
docker run my-app
```

---

# Why Not Just Install Normally?

Normal Installation:

* Install Node
* Install DB
* Install dependencies
* Configure manually
* Risk of mismatch

With Docker:

* One image
* One command
* Same result everywhere

---

# Simple Definition

Docker is a tool that packages an application and its dependencies into a container so it runs the same in any environment.

---

# 2. Understanding Kernel and Memory (Before VM vs Docker)

Before comparing Virtual Machines and Docker, we must understand:

* What is a Kernel?
* What is Memory?
* How processes use memory?

---

# What is a Kernel?

## Simple Definition

* Kernel is the **core part of an Operating System**.
* It connects:

  * Hardware
  * Software

It controls:

* CPU
* Memory
* Disk
* Network
* Devices

---

## What Kernel Does

* Process management
* Memory management
* File system control
* Device control
* Network handling
* System calls handling

Applications cannot directly access hardware.
They must go through the kernel.

---

# What is Memory?

## RAM (Random Access Memory)

* Temporary memory
* Used when application is running
* Cleared when system shuts down

---

## How Applications Use Memory

When an app runs:

1. OS loads it into RAM
2. Kernel assigns memory
3. CPU executes instructions
4. Kernel manages access

Each running app = Process

Each process gets:

* Own memory space
* Own process ID (PID)

---

# Process Isolation

* One process cannot directly access another process memory
* Kernel ensures security
* This is called isolation

---

# Why Kernel is Important for Docker?

* Docker containers share the same host kernel
* Containers do NOT include their own kernel
* That is why they are lightweight

This is the main difference between:

* Virtual Machine
* Docker Container

---

# 3. Virtual Machines vs Docker

---

# Virtual Machine (VM)

## What is a Virtual Machine?

* A VM is a full computer inside another computer.
* It includes:

  * Full OS
  * Own kernel
  * Own memory allocation
  * Own system libraries

---

## VM Architecture

Hardware
→ Hypervisor
→ Guest OS
→ App + Dependencies

---

## What is Hypervisor?

* Software that creates and manages VMs
* Examples:

  * VMware
  * VirtualBox
  * Hyper-V

---

## How VM Uses Kernel

Each VM:

* Has its own OS
* Has its own kernel
* Does NOT share host kernel

That means:

* Heavy
* More memory usage
* Slower startup

---

# Docker Container

## What is a Docker Container?

* Lightweight isolated process
* Shares host OS kernel
* Only includes app and dependencies

---

## Docker Architecture

Hardware
→ Host OS
→ Docker Engine
→ Containers

---

## How Docker Uses Kernel

* All containers share host kernel
* No separate OS inside container
* Uses Linux kernel features:

  * Namespaces (isolation)
  * Cgroups (resource control)

---

# Namespaces (Isolation)

Namespaces isolate:

* Process IDs
* Network
* File system
* User IDs

Each container thinks it is running alone.

---

# Cgroups (Control Groups)

Cgroups control:

* CPU usage
* Memory usage
* Disk I/O
* Network bandwidth

Example:

* Limit container to 512MB RAM
* Limit container to 1 CPU core

---

# VM vs Docker Comparison Table

| Feature      | Virtual Machine | Docker Container   |
| ------------ | --------------- | ------------------ |
| Kernel       | Separate kernel | Shared host kernel |
| OS           | Full OS         | No full OS         |
| Size         | Large (GBs)     | Small (MBs)        |
| Startup      | Slow            | Fast               |
| Memory Usage | High            | Low                |
| Performance  | Lower           | Near native        |
| Isolation    | Strong          | Process level      |

---

# Why Docker is Faster

Because:

* No full OS boot
* No extra kernel
* Just starts a process
* Uses host resources directly

---

# Final Clear Difference

VM:

* Virtualizes hardware

Docker:

* Virtualizes operating system

---


# 4. Docker Architecture (Detailed Internal Working)

---
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/d61e892e-d56e-4f7d-ae5a-8ac09c49c16e" />

# High Level Docker Architecture

User
→ Docker CLI
→ Docker Daemon
→ containerd
→ runc
→ Container

---

# Main Components

---

# 1. Docker Client (CLI)

## What is Docker CLI?

* Command line tool: `docker`
* Used by user to interact with Docker

Example commands:

```
docker build
docker run
docker ps
docker images
```

## What CLI Does

* Sends request to Docker Daemon
* Uses REST API
* Does NOT create containers itself

---

# 2. Docker Daemon (dockerd)

## What is Docker Daemon?

* Background service
* Main engine of Docker
* Listens for Docker API requests

## What Daemon Manages

* Images
* Containers
* Networks
* Volumes
* Build process

---

# 3. Docker Images

## What is a Docker Image?

* Read-only template
* Used to create containers
* Built from Dockerfile
* Stored in layers

Example:

```
docker build -t myapp .
```

---

## Image Layers Concept

Each instruction in Dockerfile creates a layer.

Example:

```
FROM node
COPY package.json .
RUN npm install
```

Each line = one layer

Why layers?

* Faster builds
* Reuse unchanged layers
* Efficient storage

---

# 4. Docker Containers

## What is a Container?

* Running instance of image
* Writable layer on top of image
* Isolated process

When you run:

```
docker run myapp
```

Docker:

1. Creates container from image
2. Adds writable layer
3. Starts process

---

# 5. containerd

## What is containerd?

* Container runtime manager
* Handles:

  * Container lifecycle
  * Image pulling
  * Storage
  * Execution

Docker uses containerd internally.

---

# 6. runc

## What is runc?

* Low-level container runtime
* Actually creates container process
* Uses Linux kernel features:

  * Namespaces
  * Cgroups

runc converts container definition into Linux process.

---

# 7. Docker Registry

## What is a Registry?

* Storage for Docker images
* Public or private

Examples:

* Docker Hub
* Private registry

Pull image:

```
docker pull nginx
```

Push image:

```
docker push myrepo/myapp
```

---

Internal Working Flow (Step-by-Step)

Example command:

```
docker run nginx
```

Step 1: CLI sends request to daemon
Step 2: Daemon checks if image exists
Step 3: If not, pulls image from registry
Step 4: Daemon asks containerd to create container
Step 5: containerd uses runc
Step 6: runc creates isolated process
Step 7: Container starts

---

# Important Concept: Docker Uses OS-Level Virtualization

Docker does NOT virtualize hardware.

It uses:

* Linux Namespaces → Isolation
* Cgroups → Resource control
* Union File System → Image layers

---

# Summary

Docker Architecture includes:

* CLI (user interface)
* Daemon (core engine)
* containerd (manager)
* runc (executor)
* Images (template)
* Containers (running app)
* Registry (image storage)

Everything works together to run containers efficiently.

---
No. Not only 5 things.

When Docker is installed, multiple components are installed together. The 5 main components we discussed are the core logical parts, but internally more components are also installed.

Below is the clear breakdown.

---

# What Gets Installed When Docker is Installed

## 1. Docker Engine

Main component.

Includes:

* Docker Daemon (`dockerd`)
* Docker CLI (`docker` command)

---

## 2. Docker CLI

* Command line tool
* Used to run commands:

  ```
  docker run
  docker build
  docker ps
  ```

---

## 3. Docker Daemon (dockerd)

* Background service
* Manages:

  * Images
  * Containers
  * Networks
  * Volumes

---

## 4. containerd

* Container lifecycle manager
* Pulls images
* Creates containers
* Starts/stops containers

Docker uses containerd internally.

---

## 5. runc

* Low-level runtime
* Actually creates the container process
* Uses Linux kernel features:

  * Namespaces
  * Cgroups

---

## 6. Storage Drivers

Example:

* overlay2 (most common in Linux)

Used for:

* Image layers
* Container writable layer

---

## 7. Networking Components

* Default bridge network
* Virtual Ethernet interfaces
* iptables rules

Used for:

* Container communication
* Port mapping

---

## 8. BuildKit (Modern Docker Builds)

* Improved image building
* Faster and more efficient builds

---

# Simple Answer

When Docker is installed, it installs:

* Docker CLI
* Docker Daemon
* containerd
* runc
* Storage drivers
* Networking components
* Build system

---

# 5. Dockerfile

---

# Why Dockerfile?

## Problem Without Dockerfile

If we do manually:

* Install Node
* Install dependencies
* Copy code
* Build project
* Run project

This must be repeated:

* Every time
* On every system
* On every server

This causes:

* Human errors
* Version mismatch
* Manual configuration issues

---

# What Dockerfile Solves

Dockerfile allows:

* Automated build process
* Same environment every time
* Version controlled setup
* Reproducible builds
* No manual steps

It is Infrastructure as Code for containers.

---

# What is Dockerfile?

## Definition

Dockerfile is a text file that contains instructions to build a Docker image.

Each line = one instruction.

Docker reads it from top to bottom.

---

# How Dockerfile Works

1. You write Dockerfile
2. Run:

   ```
   docker build -t myapp .
   ```
3. Docker:

   * Reads instructions
   * Executes step by step
   * Creates image
4. You run container from image

---

# Basic Structure of Dockerfile

Common instructions:

* FROM
* WORKDIR
* COPY
* ADD
* RUN
* EXPOSE
* ENV
* CMD
* ENTRYPOINT

---

# How to Write a Dockerfile (General Steps)

Step 1: Choose Base Image
Step 2: Set Working Directory
Step 3: Copy dependency files
Step 4: Install dependencies
Step 5: Copy source code
Step 6: Build application
Step 7: Expose port
Step 8: Define startup command

---

# Important Rules While Writing Dockerfile

## 1. Use Official Base Images

Example:

```
FROM node:20-alpine
```

Why?

* Secure
* Optimized
* Maintained

---

## 2. Use Small Images

Use:

* alpine versions
* slim versions

Why?

* Smaller size
* Faster download
* Better security

---

## 3. Use Layer Caching Properly

Copy dependency files first:

```
COPY package.json package-lock.json ./
RUN npm install
```

Then copy code:

```
COPY . .
```

Why?

* If code changes, dependencies layer stays cached
* Faster rebuild

---

## 4. Use .dockerignore

Avoid copying:

* node_modules
* logs
* .git

Why?

* Smaller image
* Faster build

---

# Now Dockerfile Deep Dive (Line-by-Line)

Using your example:

```
FROM node:20-alpine

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "start"]
```

---

# Line 1

```
FROM node:20-alpine
```

## What it Does

* Sets base image
* Pulls Node.js version 20
* Alpine Linux version

## Why

* Node runtime needed
* Alpine is lightweight
* Reduces image size

---

# Line 2

```
WORKDIR /app
```

## What it Does

* Sets working directory inside container
* If folder does not exist, it is created

All next commands run inside `/app`

## Why

* Clean project structure
* Avoid path confusion

---

# Line 3

```
COPY package.json package-lock.json* ./
```

## What it Does

* Copies dependency files
* From host → container `/app`

`package-lock.json*` means optional

## Why

* Separate dependency layer
* Enables build caching
* Faster rebuild

---

# Line 4

```
RUN npm install
```

## What it Does

* Installs Node dependencies
* Creates `node_modules`

## Why

* App requires dependencies to run

---

# Line 5

```
COPY . .
```

## What it Does

* Copies entire project
* Except files listed in `.dockerignore`

## Why

* Application source code needed inside container

---

# Line 6

```
RUN npm run build
```

## What it Does

* Runs build script
* Creates production build

Example:

* React build
* Next.js build
* Strapi build

## Why

* Prepares optimized version
* Reduces runtime processing

---

# Line 7

```
EXPOSE 1337
```

## What it Does

* Declares container listens on port 1337
* For documentation
* Does NOT publish port automatically

To publish:

```
docker run -p 1337:1337 image
```

---

# Line 8

```
CMD ["npm", "run", "start"]
```

## What it Does

* Default command when container starts
* Runs the application

## Why JSON Format?

* Recommended form
* Avoids shell issues
* Cleaner signal handling

---

# Important Difference

## RUN

* Executes during image build
* Creates new layer

## CMD

* Executes when container starts

---

# Build and Run Example

Build image:

```
docker build -t myapp .
```

Run container:

```
docker run -p 1337:1337 myapp
```

---

# Final Understanding

Dockerfile:

* Defines how image is built
* Automates setup
* Ensures consistency
* Uses layered architecture
* Makes deployment predictable

---

# 6. Key Docker Commands

This section covers:

* Image commands
* Container commands
* Network commands
* Volume commands
* System commands

---

# 1. Docker Image Commands

---

## 1. docker build

### Purpose

Build image from Dockerfile.

### Syntax

```
docker build [OPTIONS] PATH
```

### Example

```
docker build -t myapp:1.0 .
```

### Important Flags

| Flag          | Meaning                    |
| ------------- | -------------------------- |
| `-t`          | Tag image (name:tag)       |
| `-f`          | Specify Dockerfile name    |
| `--no-cache`  | Build without cache        |
| `--build-arg` | Pass build arguments       |
| `-q`          | Quiet mode (only image ID) |

### Example With Flags

```
docker build -t myapp:1.0 -f Dockerfile.dev --no-cache .
```

---

## 2. docker images

### Purpose

List all images.

### Syntax

```
docker images
```

### Important Flags

| Flag       | Meaning             |
| ---------- | ------------------- |
| `-a`       | Show all images     |
| `-q`       | Show only image IDs |
| `--filter` | Filter images       |

Example:

```
docker images -q
```

---

## 3. docker rmi

### Purpose

Remove image.

### Syntax

```
docker rmi IMAGE_ID
```

### Important Flags

| Flag | Meaning      |
| ---- | ------------ |
| `-f` | Force remove |

Example:

```
docker rmi -f image_id
```

---

## 4. docker pull

### Purpose

Download image from registry.

### Syntax

```
docker pull nginx
```

### Important Flags

| Flag | Meaning       |
| ---- | ------------- |
| `-a` | Pull all tags |

Example:

```
docker pull nginx:latest
```

---

## 5. docker push

### Purpose

Upload image to registry.

### Syntax

```
docker push username/image
```

---

# 2. Docker Container Commands

---

## 1. docker run

### Purpose

Create and start container.

### Syntax

```
docker run [OPTIONS] IMAGE
```

### Important Flags

| Flag        | Meaning                           |
| ----------- | --------------------------------- |
| `-d`        | Run in background (detached mode) |
| `-it`       | Interactive terminal              |
| `-p`        | Port mapping                      |
| `--name`    | Name container                    |
| `-e`        | Set environment variable          |
| `--rm`      | Remove container after stop       |
| `--network` | Connect to specific network       |
| `-v`        | Mount volume                      |
| `--restart` | Restart policy                    |
| `--memory`  | Limit memory                      |
| `--cpus`    | Limit CPU                         |

### Example

```
docker run -d -p 1337:1337 --name myapp myimage
```

### Port Mapping Explanation

```
-p host_port:container_port
```

Example:

```
-p 3000:80
```

Host 3000 → Container 80

---

## 2. docker ps

### Purpose

List running containers.

### Flags

| Flag | Meaning                 |
| ---- | ----------------------- |
| `-a` | Show all containers     |
| `-q` | Show only container IDs |

Example:

```
docker ps -a
```

---

## 3. docker stop

### Purpose

Stop running container.

### Syntax

```
docker stop container_id
```

---

## 4. docker start

### Purpose

Start stopped container.

```
docker start container_id
```

---

## 5. docker restart

### Purpose

Restart container.

```
docker restart container_id
```

---

## 6. docker rm

### Purpose

Remove container.

### Flags

| Flag | Meaning                        |
| ---- | ------------------------------ |
| `-f` | Force remove running container |

Example:

```
docker rm -f container_id
```

---

## 7. docker exec

### Purpose

Run command inside running container.

### Syntax

```
docker exec [OPTIONS] container command
```

### Important Flags

| Flag  | Meaning              |
| ----- | -------------------- |
| `-it` | Interactive terminal |
| `-u`  | Run as specific user |

Example:

```
docker exec -it mycontainer sh
```

---

## 8. docker logs

### Purpose

View container logs.

### Flags

| Flag     | Meaning         |
| -------- | --------------- |
| `-f`     | Follow logs     |
| `--tail` | Show last lines |

Example:

```
docker logs -f mycontainer
```

---

## 9. docker inspect

### Purpose

View detailed information.

```
docker inspect container_id
```

---

# 3. Docker Network Commands

---

## docker network ls

List networks:

```
docker network ls
```

---

## docker network create

Create network:

```
docker network create mynet
```

### Flags

| Flag       | Meaning                |
| ---------- | ---------------------- |
| `--driver` | Specify network driver |

Example:

```
docker network create --driver bridge mynet
```

---

## docker network inspect

```
docker network inspect mynet
```

---

## docker network rm

Remove network:

```
docker network rm mynet
```

---

# 4. Docker Volume Commands

---

## docker volume ls

List volumes:

```
docker volume ls
```

---

## docker volume create

Create volume:

```
docker volume create myvolume
```

---

## docker volume inspect

```
docker volume inspect myvolume
```

---

## docker volume rm

Remove volume:

```
docker volume rm myvolume
```

---

# 5. Docker System Commands

---

## docker system df

Show disk usage:

```
docker system df
```

---

## docker system prune

Remove unused:

```
docker system prune
```

### Flags

| Flag        | Meaning                  |
| ----------- | ------------------------ |
| `-a`        | Remove all unused images |
| `--volumes` | Remove unused volumes    |

Example:

```
docker system prune -a --volumes
```

---

## docker info

Show system information:

```
docker info
```

---

## docker version

Show Docker version:

```
docker version
```

---

# Important Real-World Example

Run full container with most flags:

```
docker run -d \
  --name myapp \
  -p 1337:1337 \
  -e NODE_ENV=production \
  --network mynet \
  -v myvolume:/data \
  --restart unless-stopped \
  --memory 512m \
  --cpus 1 \
  myimage
```

This includes:

* Detached mode
* Named container
* Port mapping
* Environment variable
* Custom network
* Volume mount
* Restart policy
* Resource limits

---

# 7. Docker Networking

---

# Why Docker Networking?

Containers need to:

* Communicate with other containers
* Communicate with the host machine
* Communicate with the internet
* Expose application ports

Without networking:

* Backend cannot talk to database
* Frontend cannot talk to backend
* Users cannot access application

---

# How Docker Networking Works

Docker creates:

* Virtual networks
* Virtual Ethernet interfaces
* Bridge interfaces
* IP address management
* iptables rules (Linux firewall rules)

Each container gets:

* Private IP address
* Network namespace (isolated network stack)

---

# Important Concept: Network Namespace

Each container has:

* Its own IP
* Its own routing table
* Its own network interfaces

But all share the same host kernel.

---

# Types of Docker Networks

Docker supports multiple network drivers.

---

# 1. Bridge Network (Default)

## What is Bridge Network?

* Default network driver
* Used when you run container without specifying network
* Works on single host

When Docker is installed, it creates:

```
bridge
```

You can see using:

```
docker network ls
```

---

## How Bridge Works

Container
→ Virtual Ethernet
→ Docker Bridge
→ Host Network
→ Internet

---

## Example

Run container:

```
docker run -d -p 3000:3000 nginx
```

Container gets:

* Private IP like 172.x.x.x
* Connected to bridge network

---

## Custom Bridge Network (Recommended)

Create network:

```
docker network create mynet
```

Run container inside network:

```
docker run -d --network mynet --name app1 nginx
docker run -d --network mynet --name app2 nginx
```

Now:

* app1 can talk to app2 using container name
* Docker provides internal DNS

Example inside container:

```
ping app2
```

---

## Why Custom Bridge is Better?

* Automatic DNS resolution
* Better isolation
* Cleaner architecture
* Recommended for multi-container apps

---

# 2. Host Network

## What is Host Network?

Container shares host network directly.

No network isolation.

---

## Example

```
docker run --network host nginx
```

Now:

* Container uses host IP
* No port mapping required
* Faster networking
* Less isolation

---

## When to Use?

* High performance applications
* Monitoring tools
* Special networking requirements

---

# 3. None Network

## What is None Network?

No network at all.

```
docker run --network none nginx
```

Container:

* Cannot access internet
* Cannot communicate

Used for:

* Security testing
* Special isolated workloads

---

# 4. Overlay Network

## What is Overlay Network?

* Used in multi-host setup
* Works with Docker Swarm
* Connects containers across multiple servers

Used for:

* Distributed systems
* Clustered applications

---

# Important Docker Network Commands

---

## List Networks

```
docker network ls
```

---

## Inspect Network

```
docker network inspect network_name
```

Shows:

* Subnet
* Gateway
* Connected containers

---

## Create Network

```
docker network create mynet
```

With driver:

```
docker network create --driver bridge mynet
```

---

## Remove Network

```
docker network rm mynet
```

---

# Port Mapping Explained

Container port ≠ Host port

Example:

```
docker run -p 8080:80 nginx
```

Means:

Host Port 8080 → Container Port 80

User accesses:

```
http://localhost:8080
```

Docker forwards traffic internally.

---

# Important Flags in Networking

| Flag        | Meaning                                      |
| ----------- | -------------------------------------------- |
| `-p`        | Publish port                                 |
| `-P`        | Publish all exposed ports                    |
| `--network` | Specify network                              |
| `--ip`      | Assign custom IP (user-defined network only) |
| `--link`    | Legacy container linking (not recommended)   |

---

# How Containers Communicate

Same network:

* Use container name
* Docker internal DNS resolves name to IP

Different networks:

* Cannot communicate unless connected manually

---

# Connect Running Container to Network

```
docker network connect mynet container_name
```

Disconnect:

```
docker network disconnect mynet container_name
```

---

# Internal Flow of Container Network

1. Docker creates network namespace
2. Creates veth pair
3. One end inside container
4. Other end connected to bridge
5. IP assigned
6. iptables rules created

---

# Security in Docker Networking

* Containers isolated by default
* Only exposed ports accessible
* Internal network hidden from host unless published
* Custom networks improve security

---

# Summary

Docker Networking provides:

* Isolation
* Container-to-container communication
* Port mapping
* Multi-host communication (overlay)
* Secure internal communication

It is built using:

* Linux namespaces
* Virtual Ethernet interfaces
* Bridge networking
* iptables

# 8. Volumes & Persistence

---

# Why Volumes Are Needed?

## Problem Without Volume

Containers are **ephemeral**.

If you:

```
docker rm container
```

All data inside container is deleted.

Example problem:

* Database container stores data
* Container crashes
* Data lost

This is not acceptable in real applications.

---

# What is Data Persistence?

Persistence means:

* Data remains even after container stops or is deleted.

Docker volumes solve this problem.

---

# What is a Docker Volume?

A Docker volume is:

* A storage area outside container filesystem
* Managed by Docker
* Stored on host machine
* Independent of container lifecycle

Container can be deleted.
Volume data remains.

---

# How Docker Storage Works

Container filesystem has:

* Read-only image layers
* Writable container layer

When container is deleted:

* Writable layer is removed
* All data inside is lost

Volumes store data outside writable layer.

---

# Types of Persistent Storage in Docker

1. Named Volume
2. Bind Mount
3. tmpfs Mount (temporary memory)

---

# 1. Named Volume

## What is Named Volume?

* Managed by Docker
* Stored in:

  ```
  /var/lib/docker/volumes/
  ```
* Portable
* Safe
* Easy to manage

---

## Create Volume

```
docker volume create myvolume
```

---

## Use Volume in Container

```
docker run -v myvolume:/data nginx
```

Meaning:

* myvolume → mounted to /data inside container

---

## Check Volumes

```
docker volume ls
```

---

## Inspect Volume

```
docker volume inspect myvolume
```

---

## Remove Volume

```
docker volume rm myvolume
```

---

# 2. Bind Mount

## What is Bind Mount?

* Mounts a host folder directly into container
* Direct mapping

Example:

```
docker run -v /home/user/data:/app/data nginx
```

Meaning:

Host path → /home/user/data
Container path → /app/data

---

## When to Use Bind Mount?

* Development environment
* Live code editing
* Access host files directly

---

## Difference Between Named Volume and Bind Mount

| Feature                   | Named Volume | Bind Mount |
| ------------------------- | ------------ | ---------- |
| Managed by Docker         | Yes          | No         |
| Path controlled by Docker | Yes          | No         |
| Easy to move              | Yes          | No         |
| Best for production       | Yes          | Usually no |
| Good for development      | Yes          | Yes        |

---

# 3. tmpfs Mount

## What is tmpfs?

* Stores data in RAM
* Not written to disk
* Temporary
* Removed after container stops

Example:

```
docker run --tmpfs /app/temp nginx
```

Used for:

* Sensitive data
* Temporary files
* Performance optimization

---

# Important Volume Flags

| Flag             | Meaning                              |
| ---------------- | ------------------------------------ |
| `-v`             | Mount volume (short syntax)          |
| `--mount`        | Advanced mount syntax                |
| `--volumes-from` | Mount volumes from another container |

---

# Modern Mount Syntax (Recommended)

Instead of:

```
-v myvolume:/data
```

Use:

```
--mount source=myvolume,target=/data,type=volume
```

Example:

```
docker run --mount source=myvolume,target=/data,type=volume nginx
```

More readable and flexible.

---

# Real Example: Database with Volume

```
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=pass \
  -v pgdata:/var/lib/postgresql/data \
  postgres
```

Now:

* Database files stored in pgdata volume
* Even if container removed
* Data remains

---

# How to Remove All Unused Volumes

```
docker volume prune
```
---

# Internal Working

When volume is mounted:

1. Docker creates volume directory
2. Mounts it into container
3. Kernel handles mount binding
4. Container writes data
5. Data stored on host

---

# Summary

Volumes provide:

* Data persistence
* Separation of storage from container
* Safe database storage
* Better architecture

Containers are temporary.
Volumes make data permanent.

---

# 9. Docker Compose

---

# Why Docker Compose?

## Problem Without Docker Compose

If your application has:

* Backend
* Database
* Redis
* Nginx

You must run manually:

```
docker network create
docker volume create
docker run db
docker run backend
docker run nginx
```

Problems:

* Too many commands
* Hard to manage
* Hard to scale
* Hard to restart properly
* Not organized

---

# What is Docker Compose?

Docker Compose is:

* A tool to define and run multi-container applications
* Uses a YAML file
* Single command to manage everything

Instead of many commands:

```
docker compose up
```

---

# What File Does Compose Use?

File name:

```
docker-compose.yml
```

Compose reads this file and creates:

* Containers
* Networks
* Volumes
* Environment variables
* Port mappings

---

# Basic Structure of docker-compose.yml

```
version: '3'

services:
  service_name:
    image:
    build:
    ports:
    volumes:
    environment:
    networks:
```

---

# Example (Backend + Database)

```
version: '3.8'

services:
  app:
    build: .
    container_name: myapp
    ports:
      - "1337:1337"
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
```

---

# Explanation Section by Section

---

# version

```
version: '3.8'
```

Defines Compose file format version.

---

# services

Main section where containers are defined.

Each service = one container.

---

# build

```
build: .
```

Builds image from Dockerfile in current directory.

Alternative:

```
build:
  context: .
  dockerfile: Dockerfile.dev
```

---

# image

```
image: postgres:15
```

Uses existing image from Docker Hub.

---

# container_name

```
container_name: myapp
```

Sets fixed container name.

---

# ports

```
ports:
  - "1337:1337"
```

Host port → Container port

Format:

```
"host:container"
```

---

# environment

```
environment:
  - NODE_ENV=production
```

Sets environment variables inside container.

Alternative syntax:

```
environment:
  NODE_ENV: production
```

---

# volumes

```
volumes:
  - db-data:/var/lib/postgresql/data
```

Mounts named volume.

Format:

```
volume_name:container_path
```

---

# depends_on

```
depends_on:
  - db
```

Ensures:

* db container starts before app

Important:

* Does NOT wait for DB to be ready
* Only ensures start order

---

# networks

```
networks:
  - app-network
```

Connects service to custom network.

---

# Top-Level volumes

```
volumes:
  db-data:
```

Creates named volume.

---

# Top-Level networks

```
networks:
  app-network:
```

Creates custom network.

---

# Important Docker Compose Commands

---

## docker compose up

Start services:

```
docker compose up
```

---

## docker compose up -d

Detached mode:

```
docker compose up -d
```

---

## docker compose down

Stop and remove containers:

```
docker compose down
```

With volumes:

```
docker compose down -v
```

---

## docker compose build

Build services:

```
docker compose build
```

Rebuild without cache:

```
docker compose build --no-cache
```

---

## docker compose ps

List running services:

```
docker compose ps
```

---

## docker compose logs

View logs:

```
docker compose logs
```

Follow logs:

```
docker compose logs -f
```

---

## docker compose restart

Restart services:

```
docker compose restart
```

---

## docker compose stop

Stop services without removing:

```
docker compose stop
```

---

# How Compose Works Internally

When you run:

```
docker compose up
```

Compose:

1. Reads YAML file
2. Creates networks
3. Creates volumes
4. Builds images (if needed)
5. Starts containers
6. Connects containers

All automatically.

---

# Benefits of Docker Compose

* Single configuration file
* Clean architecture
* Easy scaling
* Easy restart
* Better readability
* Infrastructure as Code

---

# Scaling Example

```
docker compose up --scale app=3
```

Creates:

* 3 app containers
* Load balanced internally

---

# Best Practices

* Use custom networks
* Use named volumes
* Use environment variables
* Avoid hardcoding secrets
* Keep services separated

---

# Compose vs Docker Run

| Feature                | docker run | docker compose |
| ---------------------- | ---------- | -------------- |
| Single container       | Yes        | Yes            |
| Multi container        | Hard       | Easy           |
| Reproducible setup     | Manual     | Automatic      |
| Clean architecture     | No         | Yes            |
| Infrastructure as Code | No         | Yes            |

---

# Final Summary

Docker Compose:

* Manages multi-container applications
* Uses YAML configuration
* Simplifies container orchestration
* Essential for real projects
* Makes development and deployment easier

---



