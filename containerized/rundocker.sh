#!/bin/bash
## If crash at docker step, don't be scare or upset.
## Rerun this again, should works now

N8N_S_COOKIE=false
N8N_WEBHOOK="localhost"
N8N_USER="test"
N8N_PASSWORD="test"
DOMAINNAME="localhost"
docker pull n8nio/n8n;
chown -R 1000:1000 ~/.n8n
chmod -R 755 ~/.n8n
sudo docker start n8n
sudo docker stop n8n
sudo docker rm n8n
docker run -d --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=$N8N_USER \
  -e N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD \
  -e N8N_HOST=$DOMAINNAME \
  -e N8N_PORT=5678 \
  -e N8N_SECURE_COOKIE=$N8N_S_COOKIE \
  -e WEBHOOK_URL=http://$N8N_WEBHOOK \
  -e GENERIC_TIMEZONE=Asia/Bangkok \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
sudo docker ps    
