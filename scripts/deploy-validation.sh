#!/bin/bash

# ================================================
# Deploy SSL Validation File
# ================================================

set -e

echo "================================================"
echo "Deploying SSL Validation File"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

VALIDATION_FILE="DD420E628EDFB75596E4438A876F43EB.txt"

if [ ! -f "ca/showcase/$VALIDATION_FILE" ]; then
    echo "✗ Error: ca/showcase/$VALIDATION_FILE not found!"
    exit 1
fi

echo ""
echo "Found validation file: ca/showcase/$VALIDATION_FILE"
echo "Deploying to: http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

# Upload and deploy
if [ -n "$VPS_PASSWORD" ]; then
    # Upload file
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        "ca/showcase/$VALIDATION_FILE" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Deploy on VPS
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" << 'ENDSSH'
set -e

echo "Creating directory structure..."
sudo mkdir -p /var/www/showcase-app/public/.well-known/pki-validation
sudo chmod -R 755 /var/www/showcase-app/public/.well-known

echo "Moving validation file..."
sudo mv /tmp/DD420E628EDFB75596E4438A876F43EB.txt /var/www/showcase-app/public/.well-known/pki-validation/
sudo chmod 644 /var/www/showcase-app/public/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt

echo "✓ File deployed"

echo ""
echo "Updating Nginx configuration..."

# Update Nginx config to serve .well-known via HTTP
sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation and redirect
server {
    listen 80;
    server_name showcase.vibytes.tech;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/showcase-app/public;
        try_files $uri $uri/ =404;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS
server {
    listen 443 ssl;
    server_name showcase.vibytes.tech;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/showcase-vibytes-tech.crt;
    ssl_certificate_key /etc/nginx/ssl/showcase-vibytes-tech.key;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Increase upload size for 3D models
    client_max_body_size 100M;
}
NGINXCONF

echo "✓ Nginx config updated"

echo ""
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "✓ Nginx reloaded"

echo ""
echo "================================================"
echo "Testing Validation File Access"
echo "================================================"
echo ""
echo "Testing via localhost..."
if curl -sf http://localhost/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt > /dev/null; then
    echo "✓ File is accessible!"
    echo ""
    echo "File content:"
    curl -s http://localhost/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt
else
    echo "✗ File is not accessible"
    echo ""
    echo "Checking file existence..."
    ls -la /var/www/showcase-app/public/.well-known/pki-validation/
fi

ENDSSH
else
    # Using SSH key
    # Upload file
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        "ca/showcase/$VALIDATION_FILE" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Deploy on VPS
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" << 'ENDSSH'
set -e

echo "Creating directory structure..."
sudo mkdir -p /var/www/showcase-app/public/.well-known/pki-validation
sudo chmod -R 755 /var/www/showcase-app/public/.well-known

echo "Moving validation file..."
sudo mv /tmp/DD420E628EDFB75596E4438A876F43EB.txt /var/www/showcase-app/public/.well-known/pki-validation/
sudo chmod 644 /var/www/showcase-app/public/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt

echo "✓ File deployed"

echo ""
echo "Updating Nginx configuration..."

# Update Nginx config to serve .well-known via HTTP
sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation and redirect
server {
    listen 80;
    server_name showcase.vibytes.tech;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/showcase-app/public;
        try_files $uri $uri/ =404;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS
server {
    listen 443 ssl;
    server_name showcase.vibytes.tech;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/showcase-vibytes-tech.crt;
    ssl_certificate_key /etc/nginx/ssl/showcase-vibytes-tech.key;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Increase upload size for 3D models
    client_max_body_size 100M;
}
NGINXCONF

echo "✓ Nginx config updated"

echo ""
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "✓ Nginx reloaded"

echo ""
echo "================================================"
echo "Testing Validation File Access"
echo "================================================"
echo ""
echo "Testing via localhost..."
if curl -sf http://localhost/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt > /dev/null; then
    echo "✓ File is accessible!"
    echo ""
    echo "File content:"
    curl -s http://localhost/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt
else
    echo "✗ File is not accessible"
    echo ""
    echo "Checking file existence..."
    ls -la /var/www/showcase-app/public/.well-known/pki-validation/
fi

ENDSSH
fi

echo ""
echo "================================================"
echo "✅ Deployment Complete!"
echo "================================================"
echo ""
echo "Validation URL:"
echo "  http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""
echo "Next steps:"
echo "  1. Go to your SSL provider's website"
echo "  2. Click 'Validate' or 'Check Domain' button"
echo "  3. Wait for validation (5-30 minutes)"
echo "  4. Download issued certificates when ready"
echo ""
echo "Test URL in browser:"
echo "  http://showcase.vibytes.tech/.well-known/pki-validation/DD420E628EDFB75596E4438A876F43EB.txt"
echo ""

