#!/bin/bash

apt update -y
apt install -y docker.io awscli

systemctl start docker
systemctl enable docker

aws ecr get-login-password --region us-east-1 \
| docker login --username AWS --password-stdin ${ecr_url}

docker pull ${ecr_url}:${image_tag}

docker stop strapi || true
docker rm strapi || true

docker run -d -p 1337:1337 --name strapi --restart unless-stopped ${ecr_url}:${image_tag}
