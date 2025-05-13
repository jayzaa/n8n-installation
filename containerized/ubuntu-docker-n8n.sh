#!/bin/bash
### Install n8n with reverse proxy (Containerized Mode)
### Writer: Jayzaa 
### This script will
### 0. Change Timezone to Thailand Time
### 1. Create 2GB of Swap File
### 2. Auto Mount Swap File
### 3. Update Ubuntu to latest version
### 4. Install Docker
### 5. Install nginx and set as reverse proxy for n8n
### 

### Your Domain Name, use localhost if you don't have and preferred to use ip address
DOMAINNAME="localhost"
N8N_USER="test"
N8N_PASSWORD="test"
N8N_WEBHOOK="http://localhost"
if [ "$DOMAIN_NAME" = "localhost" ]; then
    export N8N_SECURE_COOKIE=false
else
    export N8N_SECURE_COOKIE=true
fi

#Swap Size 
SWAPSIZE="2G"
### Change Timezone
sudo cp /usr/share/zoneinfo/Asia/Bangkok /etc/localtime;
### Swap
sudo fallocate -l $SWAPSIZE /swapfile
ls -lh /swapfile
sudo chmod 600 /swapfile
ls -lh /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
### Install Pre-Requisites
sudo apt update -y;
sudo apt upgrade -y;
sudo apt reinstall --allow-change-held-packages -y cloud-init ;

### Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sleep 10
echo "Wait for Signing Key on repository"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo docker --version
#### Install Certificate Related
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common;
sudo apt install -y nginx certbot python3-certbot-nginx;
sudo systemctl enable nginx; 
sudo rm -f /etc/nginx/sites-enabled/* /etc/nginx/sites-available/* /etc/nginx/conf.d/*
## Create Reverse Proxy for n8n
sudo touch /etc/nginx/conf.d/n8n_proxy.conf
cat <<EOF | sudo tee /etc/nginx/conf.d/n8n_proxy.conf > /dev/null
server {
    server_name $DOMAINNAME;

    location / {
        proxy_pass http://localhost:5678;  # Forward requests to n8n
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    listen 80;
}
EOF

sudo nginx -t;
sudo systemctl restart nginx;
curl -I http://$DOMAINNAME;
echo "This should return Error 502 due to No Backend Running";


#Docker for n8n
sudo docker pull n8nio/n8n;
sudo docker run -d --name n8n -p 5678:5678 n8nio/n8n;
sleep 5;
curl -I http://$DOMAINNAME:5678;
sudo chown -R 1000:1000 ~/.n8n
sudo chmod -R 755 ~/.n8n
sudo docker start n8n
sudo docker stop n8n && sudo docker rm n8n #Remove old Container Session
sudo docker run -d --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=$N8N_USER \
  -e N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD \
  -e N8N_HOST=$DOMAINNAME \
  -e N8N_PORT=5678 \
  -e N8N_SECURE_COOKIE=$N8N_SECURE_COOKIE \
  -e WEBHOOK_URL=$N8N_WEBHOOK \
  -e GENERIC_TIMEZONE=UTC \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
sleep 5;
curl -I http://$DOMAINNAME:5678;
curl -I http://$DOMAINNAME;

  ### Uncomment if need to run certbot, Currently use localhost
  #sudo certbot --nginx -d $DOMAINNAME;
  #sudo certbot renew
  # Every 3 AM, Certbot will renew
  #(sudo crontab -l 2>/dev/null; echo '0 3 * * * certbot renew --quiet --post-hook "systemctl restart nginx"') | sudo crontab -
