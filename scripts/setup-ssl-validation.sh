#!/bin/bash

# ================================================
# SSL Domain Validation Setup
# ================================================
# Tạo file validation cho SSL provider
# ================================================

set -e

echo "================================================"
echo "SSL Domain Validation Setup"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

# Get validation file name and content
read -p "Enter validation filename (e.g., DD420E628EDFB75596E4438A876F43EB.txt): " VALIDATION_FILE
read -p "Enter validation content (paste from SSL provider): " VALIDATION_CONTENT

echo ""
echo "Configuration:"
echo "  Domain: $APP_DOMAIN"
echo "  File: $VALIDATION_FILE"
echo "  Path: /.well-known/pki-validation/$VALIDATION_FILE"
echo ""

# Create validation setup script
cat > /tmp/ssl-validation-script.sh << REMOTESCRIPT
#!/bin/bash
set -e

echo "================================================"
echo "Creating SSL Validation File"
echo "================================================"

# Create directory structure
sudo mkdir -p /var/www/showcase-app/public/.well-known/pki-validation
sudo chmod -R 755 /var/www/showcase-app/public/.well-known

# Create validation file
echo "$VALIDATION_CONTENT" | sudo tee /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE > /dev/null

sudo chmod 644 /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE

echo "✓ Validation file created at:"
echo "  /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE"

echo ""
echo "================================================"
echo "Updating Nginx Configuration"
echo "================================================"

# Update Nginx to serve .well-known directory
sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation
server {
    listen 80;
    server_name APP_DOMAIN;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/showcase-app/public;
        allow all;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://\$server_name\$request_uri;
    }
}

# HTTPS
server {
    listen 443 ssl;
    server_name APP_DOMAIN;

    # SSL Configuration (using self-signed for now)
    ssl_certificate /etc/nginx/ssl/showcase-vibytes-tech.crt;
    ssl_certificate_key /etc/nginx/ssl/showcase-vibytes-tech.key;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # SSL Session
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location / {
        proxy_pass http://localhost:APP_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    # Increase upload size for 3D models
    client_max_body_size 100M;
}
NGINXCONF

# Replace placeholders
sudo sed -i "s/APP_DOMAIN/$APP_DOMAIN/g" /etc/nginx/sites-available/showcase-app
sudo sed -i "s/APP_PORT/$APP_PORT/g" /etc/nginx/sites-available/showcase-app

echo "✓ Nginx config updated"

# Test and reload Nginx
echo ""
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "================================================"
echo "Testing Validation File"
echo "================================================"

# Test file access
echo ""
echo "Testing HTTP access..."
if curl -sf http://localhost/.well-known/pki-validation/$VALIDATION_FILE > /dev/null; then
    echo "✓ Validation file is accessible via HTTP"
    echo ""
    echo "File content:"
    curl -s http://localhost/.well-known/pki-validation/$VALIDATION_FILE
else
    echo "✗ Warning: File might not be accessible"
fi

echo ""
echo "================================================"
echo "Validation Setup Complete!"
echo "================================================"
echo ""
echo "Your validation file is now accessible at:"
echo "  http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""
echo "Next steps:"
echo "  1. Go back to your SSL provider's website"
echo "  2. Click 'Validate' or 'Check' button"
echo "  3. Wait for validation to complete (usually 5-30 minutes)"
echo "  4. Download the issued SSL certificates"
echo "  5. Replace self-signed certificates with real ones"
echo ""

REMOTESCRIPT

# Execute on VPS
echo "Executing validation setup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-validation-script.sh" < /tmp/ssl-validation-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export VALIDATION_FILE='$VALIDATION_FILE' && \
         export VALIDATION_CONTENT='$VALIDATION_CONTENT' && \
         bash /tmp/ssl-validation-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-validation-script.sh" < /tmp/ssl-validation-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export VALIDATION_FILE='$VALIDATION_FILE' && \
         export VALIDATION_CONTENT='$VALIDATION_CONTENT' && \
         bash /tmp/ssl-validation-script.sh"
fi

echo ""
echo "✅ Validation file deployed successfully!"
echo ""
echo "Test URL: http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

