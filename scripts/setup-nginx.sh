#!/bin/bash

# ================================================
# Nginx Setup Script
# ================================================
# Configure Nginx reverse proxy and SSL
# ================================================

set -e

echo "================================================"
echo "Nginx Configuration Script"
echo "================================================"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "✗ Error: .env not found!"
    exit 1
fi

echo ""
echo "Nginx Configuration:"
echo "-------------------"
echo "App Domain: $APP_DOMAIN"
echo "Keycloak Domain: $KEYCLOAK_DOMAIN"
echo "SSL: $USE_SSL"
echo "Email: $SSL_EMAIL"
echo ""

# Create nginx configuration script
cat > /tmp/nginx-setup-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Configuring Nginx"
echo "================================================"

# Configure App
echo "Creating Nginx configuration for $APP_DOMAIN..."

sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
server {
    listen 80;
    server_name APP_DOMAIN;

    location / {
        proxy_pass http://localhost:APP_PORT;
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

# Replace placeholders
sudo sed -i "s/APP_DOMAIN/$APP_DOMAIN/g" /etc/nginx/sites-available/showcase-app
sudo sed -i "s/APP_PORT/$APP_PORT/g" /etc/nginx/sites-available/showcase-app

# Configure Keycloak
echo "Creating Nginx configuration for $KEYCLOAK_DOMAIN..."

sudo tee /etc/nginx/sites-available/keycloak > /dev/null << 'NGINXCONF'
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_cache_bypass $http_upgrade;
        
        # Buffer settings for Keycloak
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
        
        # Timeouts
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
NGINXCONF

# Replace placeholders
sudo sed -i "s/KEYCLOAK_DOMAIN/$KEYCLOAK_DOMAIN/g" /etc/nginx/sites-available/keycloak

# Enable sites
sudo ln -sf /etc/nginx/sites-available/showcase-app /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✓ Nginx configured"

# Setup SSL if enabled
if [ "$USE_SSL" = "true" ]; then
    echo ""
    echo "================================================"
    echo "Setting Up SSL with Let's Encrypt"
    echo "================================================"
    
    echo "Obtaining SSL certificate for $APP_DOMAIN..."
    sudo certbot --nginx -d $APP_DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL --redirect || echo "Warning: SSL setup for app failed"
    
    echo "Obtaining SSL certificate for $KEYCLOAK_DOMAIN..."
    sudo certbot --nginx -d $KEYCLOAK_DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL --redirect || echo "Warning: SSL setup for Keycloak failed"
    
    # Test renewal
    echo "Testing certificate renewal..."
    sudo certbot renew --dry-run || echo "Warning: Renewal test failed"
    
    echo "✓ SSL configured"
fi

echo ""
echo "================================================"
echo "Nginx Configuration Complete!"
echo "================================================"
echo ""
echo "Sites configured:"
echo "  - $APP_DOMAIN → http://localhost:$APP_PORT"
echo "  - $KEYCLOAK_DOMAIN → http://localhost:8080"
echo ""
if [ "$USE_SSL" = "true" ]; then
    echo "SSL Status:"
    echo "  - HTTPS enabled"
    echo "  - Auto-renewal configured"
    echo ""
    echo "Access your sites at:"
    echo "  - https://$APP_DOMAIN"
    echo "  - https://$KEYCLOAK_DOMAIN"
else
    echo "Access your sites at:"
    echo "  - http://$APP_DOMAIN"
    echo "  - http://$KEYCLOAK_DOMAIN"
fi
echo ""
echo "Useful commands:"
echo "  sudo nginx -t              # Test configuration"
echo "  sudo systemctl reload nginx  # Reload Nginx"
echo "  sudo certbot certificates  # View SSL certificates"
echo "  sudo certbot renew        # Renew certificates"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing Nginx setup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-setup-script.sh" < /tmp/nginx-setup-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export USE_SSL='$USE_SSL' && \
         export SSL_EMAIL='$SSL_EMAIL' && \
         bash /tmp/nginx-setup-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-setup-script.sh" < /tmp/nginx-setup-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export USE_SSL='$USE_SSL' && \
         export SSL_EMAIL='$SSL_EMAIL' && \
         bash /tmp/nginx-setup-script.sh"
fi

echo ""
echo "✓ Nginx setup completed successfully!"
echo ""

