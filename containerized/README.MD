🚀 N8N Docker + Nginx Reverse Proxy Installer (Ubuntu)

⚠️ Try at your own risk. This script configures a production-level service using elevated privileges.

📋 Overview

This script installs n8n in a containerized environment using Docker, and sets up an Nginx reverse proxy with optional HTTPS. It's designed for quick setups and testing environments.

💠 What the Script Does

Sets timezone to Asia/Bangkok

Creates and mounts a 2GB swap file

Updates the system

Installs Docker and Nginx

Sets up Nginx reverse proxy to forward traffic to n8n

Deploys n8n in a Docker container

Optionally sets up Certbot (commented out by default)

⚠️ Important Notes

🧑‍💻 Run with sudo

This script requires root privileges. Always run with sudo:

sudo ./install_n8n.sh

🐳 Docker runs with root privileges

This script starts the n8n Docker container as root.

⚠️ Developers must take responsibility for the security risks:

The container has full root access to the host.

You should review and modify Docker run parameters as needed.

It's best to run in a controlled, closed ecosystem or test environment.

🧪 Use at your own risk

This script is provided as-is and assumes you're familiar with Linux administration, Docker, and Nginx. It makes system-level changes (timezone, packages, Docker, swap).

💻 Minimum Machine Requirements

At least 2 vCPU

At least 2 GB RAM

Running n8n below this spec may result in:

Docker crashes

High CPU/memory pressure

Nginx failures

🔧 Configurable Variables in the Script

You can modify these at the top of the script:

DOMAINNAME="localhost"
N8N_USER="test"
N8N_PASSWORD="test"
N8N_WEBHOOK="http://localhost"

📝 Optional HTTPS

To enable HTTPS with Let's Encrypt:

Point your domain to the server IP.

Uncomment the Certbot section at the bottom of the script.

Replace localhost with your actual domain name.

✅ After Install

Access n8n via: http://your-domain or http://server-ip

Default credentials: set via $N8N_USER and $N8N_PASSWORD

