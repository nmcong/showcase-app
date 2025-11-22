#!/bin/bash

# Simple Nginx setup for showcase-only (no Keycloak)

set -e

echo "================================================"
echo "Nginx Setup for Showcase"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "Configuration:"
echo "------------------------"
echo "VPS: $VPS_USER@$VPS_HOST"
echo "Domain: $APP_DOMAIN"
echo "Port: $APP_PORT"
echo ""

# Create Nginx configuration script
cat > /tmp/nginx-setup.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Configuring Nginx"
echo "================================================"

# Create Nginx config for showcase
sudo tee /etc/nginx/sites-available/showcase > /dev/null << NGINXCONF
server {
    listen 80;
    server_name $APP_DOMAIN;

    # Redirect HTTP to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $APP_DOMAIN;

    # SSL certificates (will be configured with certbot or your certificates)
    ssl_certificate /etc/letsencrypt/live/$APP_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$APP_DOMAIN/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Proxy to Next.js app
    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files caching
    location /_next/static {
        proxy_pass http://localhost:$APP_PORT;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # Models and assets caching
    location /models {
        proxy_pass http://localhost:$APP_PORT;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    # Client max body size (for uploads if needed)
    client_max_body_size 100M;
}
NGINXCONF

# Enable site
sudo ln -sf /etc/nginx/sites-available/showcase /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
sudo nginx -t

echo "✓ Nginx configuration created"

echo ""
echo "================================================"
echo "SSL Certificate Setup"
echo "================================================"
echo ""
echo "Choose SSL setup method:"
echo "1. Let's Encrypt (free, automatic)"
echo "2. Custom certificates (manual)"
echo ""

# Auto-select Let's Encrypt for now
echo "Setting up Let's Encrypt..."

# Install certbot if not installed
if ! command -v certbot &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y certbot python3-certbot-nginx
fi

# Temporarily use HTTP-only config for certbot
sudo tee /etc/nginx/sites-available/showcase > /dev/null << NGINXCONF_TEMP
server {
    listen 80;
    server_name $APP_DOMAIN;

    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINXCONF_TEMP

sudo nginx -t && sudo systemctl reload nginx

# Get SSL certificate
echo "Obtaining SSL certificate..."
sudo certbot --nginx -d $APP_DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL --redirect

echo "✓ SSL certificate obtained"

# Setup auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

echo "✓ Auto-renewal configured"

# Reload Nginx
sudo systemctl reload nginx

echo ""
echo "================================================"
echo "Nginx Configuration Complete!"
echo "================================================"
echo ""
echo "Your app should now be accessible at:"
echo "  https://$APP_DOMAIN"
echo ""
echo "Nginx commands:"
echo "  sudo systemctl status nginx"
echo "  sudo systemctl restart nginx"
echo "  sudo systemctl reload nginx"
echo "  sudo nginx -t"
echo ""
echo "SSL certificate will auto-renew via certbot."
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing Nginx setup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-setup.sh" < /tmp/nginx-setup.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export SSL_EMAIL='$SSL_EMAIL' && \
         bash /tmp/nginx-setup.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-setup.sh" < /tmp/nginx-setup.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export SSL_EMAIL='$SSL_EMAIL' && \
         bash /tmp/nginx-setup.sh"
fi

echo ""
echo "✓ Nginx setup completed successfully!"
echo ""

