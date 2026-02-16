#!/bin/bash
apt update -y
apt install -y docker.io awscli

systemctl start docker
systemctl enable docker

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ecr_url}

docker pull ${ecr_url}:${image_tag}

docker stop strapi || true
docker rm strapi || true

docker run -d -p 1337:1337 --name strapi --restart unless-stopped -e APP_KEYS="key1,key2,key3,key4" -e ADMIN_JWT_SECRET="supersecretadmin" -e JWT_SECRET="supersecretjwt" -e API_TOKEN_SALT="b+SDaA9Dgc3hgZNJGthQjQ==" -e NODE_ENV=production ${ecr_url}:${image_tag}
