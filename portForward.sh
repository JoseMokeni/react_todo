#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <minikube_ip> <node_port>"
    exit 1
fi

minikubeip=$1
nodeport=$2

# Update package lists
sudo apt-get update -y

# Install Nginx
sudo apt-get install nginx -y

# Remove the default Nginx site if it exists
if [ -e /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Create a new Nginx configuration file
sudo bash -c "cat > /etc/nginx/sites-available/minikube-proxy <<EOF
server {
    listen 80;
    location / {
        proxy_pass http://$minikubeip:$nodeport;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF"

# Enable the new site
sudo ln -s /etc/nginx/sites-available/minikube-proxy /etc/nginx/sites-enabled/

# Test the Nginx configuration
sudo nginx -t

# Reload Nginx to apply the changes
sudo systemctl reload nginx