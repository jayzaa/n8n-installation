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
### 6. As your own risk

### Your Domain Name, use localhost if you don't have and preferred to use ip address
DOMAINNAME="localhost"
N8N_USER="test"
N8N_PASSWORD="test"
N8N_WEBHOOK="localhost"
N8N_S_COOKIE=false
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
### NodeJS Repository (Current n8n support 18)
curl -fsSL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
sudo -E bash nodesource_setup.sh
echo "Run OS Patches and Fetch Repos"
sudo apt update -y;
sudo apt upgrade -y;
sudo apt reinstall --allow-change-held-packages -y cloud-init;
sudo apt autoremove -y;
#### Install Certificate Related
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common;
sudo apt install -y nginx certbot python3-certbot-nginx nodejs;
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

node -v;
npm -v;
sudo npm install update;
sudo npm install -g n8n;

echo "You can try to run n8n"
echo "You can try screen -S n8n to create screen session and run n8n inside"
echo "To detach screen, use CTRL+A then D. If you need re-attach, run screen -R n8n"  


  ### Uncomment if need to run certbot, Currently use localhost
  #sudo certbot --nginx -d $DOMAINNAME;
  #sudo certbot renew
  # Every 3 AM, Certbot will renew
  #(sudo crontab -l 2>/dev/null; echo '0 3 * * * certbot renew --quiet --post-hook "systemctl restart nginx"') | sudo crontab -
