## This script tested on 
## Ubuntu Linux 24.04 LTS (Noble Nombat)
## 1. AlibabaCloud (Aliyun) Simple Application Server (2vCPU / 1GB RAM / 30GB SSD)
## 2. AlibabaCloud (Aliyun) Elastic Compute Service (2vCPU / 4GB RAM / 20GB SSD)
## 3. Google Cloud Platform  Compute Engine (2vCPU / 4GB RAM / 20GB Balanced Disk)

## If you want to try AlibabaCloud: [Click Here to try](https://www.alibabacloud.com/campaign/benefits?referral_code=A9ESHA)
## 9.9$ per year on AlibabaCloud Simple Application Server [Click Here to see Offer](https://www.alibabacloud.com/campaign/benefits?_p_lc=1&referral_code=A9ESHA#J_7789915720)
### Intel Xeon Platinum / 2 vCPU / 1GB RAM / 30GB SSD / 200mbps Network / Thailand (Bangkok) region support / 1 IPv4
# 🚀 N8N Docker + Nginx Reverse Proxy Installer (Ubuntu)

> ⚠️ **Try at your own risk. This script configures a production-level service using elevated privileges.**

---

## 📋 Overview

This script installs [n8n](https://n8n.io) in a containerized environment using Docker and sets up an Nginx reverse proxy with optional HTTPS. It's ideal for quick deployment or staging environments.

---

## 🛠️ What the Script Does

* Sets timezone to **Asia/Bangkok**
* Creates and mounts a **2GB swap file**
* Updates the system to the latest packages
* Installs **Docker** and **Nginx**
* Configures **Nginx** as a reverse proxy for n8n
* Deploys **n8n** using Docker
* Includes optional setup for **Let's Encrypt SSL (Certbot)**

---

## ⚠️ Important Notes

### 🔐 Run with `sudo`

This script makes system-level changes. Always run it using `sudo`:

```bash
sudo ./install_n8n.sh
```

### 🐳 Docker and Root Privileges

The n8n Docker container runs as root. You **must take responsibility** for the associated risks:

* Docker containers have high privileges by default
* Security must be managed manually
* It is recommend to have basic administration , or use cloud firewall to denied bad traffic.
