#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello, World!" > /var/www/html/index.html
service nginx start
