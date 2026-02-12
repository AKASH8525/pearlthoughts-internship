#!/bin/bash
apt update -y
apt install -y docker.io

systemctl start docker
systemctl enable docker

usermod -aG docker ubuntu

docker pull akash2627/strapi-devops:day4

docker run -d -p 1337:1337 --name strapi-container akash2627/strapi-devops:day4

