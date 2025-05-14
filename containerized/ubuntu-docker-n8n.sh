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
### 6. FYI, As your own risk, if container failed to run, run this script again, this should works.

## This script tested on AlibabaCloud (Aliyun) Server, Result may different from another (but mostly OS level shouldn't be changes)
## If you want to try AlibabaCloud: [Click Here to try](https://www.alibabacloud.com/campaign/benefits?referral_code=A9ESHA)
## 9.9$ per year on AlibabaCloud Simple Application Server [Click Here to see Offer](https://www.alibabacloud.com/campaign/benefits?_p_lc=1&referral_code=A9ESHA#J_7789915720)
### Intel Xeon Platinum / 2 vCPU / 1GB RAM / 30GB SSD / 200mbps Network / Thailand (Bangkok) region support / 1 IPv4

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
echo "Setup Docker Repo"
sudo apt install -y gpg dialog;
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Run OS Patches and Fetch Repos"
sudo apt update -y;
sudo apt upgrade -y;
sudo apt reinstall --allow-change-held-packages -y cloud-init;
sudo apt autoremove -y;
#### Install Pre-Requisites Ubuntu App
sudo apt install -y vim systemd-cron inetutils-ping
#### Install Certificate Related
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common;
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
echo "Test First Curl to nginx"
curl -I --connect-timeout 10 --max-time 30 http://$DOMAINNAME;
echo "This should return Error 502 due to No Backend Running";


#Docker for n8n
echo "Waiting for 20 seconds..."
sleep 20
echo "Done waiting."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
docker --version

docker pull n8nio/n8n;
docker run -d --name n8n -p 5678:5678 n8nio/n8n;
sleep 5;
curl -I http://$DOMAINNAME:5678;
chown -R 1000:1000 ~/.n8n
chmod -R 755 ~/.n8n
docker start n8n
docker stop n8n 
docker rm n8n
sleep 10;
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
sleep 5;
echo "Test Call to n8n"
curl -I --connect-timeout 10 --max-time 30 http://$DOMAINNAME:5678;
echo "Test Call to n8n with reverse proxy"
curl -I --connect-timeout 10 --max-time 30 http://$DOMAINNAME;

  ### Uncomment if need to run certbot, Currently use localhost
  #sudo certbot --nginx -d $DOMAINNAME;
  #sudo certbot renew
  # Every 3 AM, Certbot will renew
  #(sudo crontab -l 2>/dev/null; echo '0 3 * * * certbot renew --quiet --post-hook "systemctl restart nginx"') | sudo crontab -
  #sudo systemctl restart nginx

