#!/usr/bin/env bash
# This script sets up web servers for the deployment of web_static

# Exit the script if any command fails
set -e

# Check if nginx is installed, and install it if not
if ! command -v nginx &> /dev/null; then
    sudo apt update
    sudo apt install nginx -y
fi

# Create directory structure for web_static
sudo mkdir -p "/data/web_static/releases/test/"
sudo mkdir -p "/data/web_static/shared/"

# Create HTML content
body_content="Holberton School Web site under construction!"
current_date=$(date +"%Y-%m-%d %H:%M:%S")
html_content="<html>
  <head></head>
  <body>$body_content</body>
  <p>Generated on: $current_date</p>
</html>"

# Write HTML content to index.html
echo "$html_content" | sudo tee /data/web_static/releases/test/index.html > /dev/null

# Remove existing /data/web_static/current and create a symbolic link
sudo rm -rf /data/web_static/current
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

# Set ownership to the ubuntu user
sudo chown -R ubuntu:ubuntu /data/

# Download nginx default configuration file from exampleconfig.com
sudo wget -q -O /etc/nginx/sites-available/default http://exampleconfig.com/static/raw/nginx/ubuntu20.04/etc/nginx/sites-available/default

# Create a simple "Hello World" index.html in /var/www/html
echo 'Holberton School Hello World!' | sudo tee /var/www/html/index.html > /dev/null

# Configure nginx to add custom locations and headers
config="/etc/nginx/sites-available/default"
sudo sed -i '/^}$/i \ \n\tlocation \/redirect_me {return 301 https:\/\/www.youtube.com\/watch?v=QH2-TGUlwu4;}' $config
sudo sed -i '/^}$/i \ \n\tlocation @404 {return 404 "Ceci n'\''est pas une page\\n";}' $config
sudo sed -i 's/=404/@404/g' $config
sudo sed -i "/^server {/a \ \tadd_header X-Served-By $HOSTNAME;" $config
sudo sed -i '/^server {/a \ \n\tlocation \/hbnb_static {alias /data/web_static/current/;index index.html;}' $config

# Restart nginx to apply changes
sudo service nginx restart

