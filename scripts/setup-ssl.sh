#!/bin/bash

# ================================================
# SSL Setup Script for Both Domains
# ================================================
# Setup SSL certificates cho auth.vibytes.tech và showcase.vibytes.tech
# ================================================

set -e

echo "================================================"
echo "SSL Setup Script"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

# Validate certificates exist
echo ""
echo "Validating local certificates..."

# Check auth certificates
if [ ! -f "ca/auth/private_key_auth-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/auth/private_key_auth-vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/auth/certificate_auth-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/auth/certificate_auth-vibytes-tech.txt not found!"
    echo "  Run: ./scripts/generate-self-signed-certs.sh"
    exit 1
fi

# Check showcase certificates
if [ ! -f "ca/showcase/private_key_showcase-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/showcase/private_key_showcase-vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/showcase/certificate_showcase-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/showcase/certificate_showcase-vibytes-tech.txt not found!"
    echo "  Run: ./scripts/generate-self-signed-certs.sh"
    exit 1
fi

echo "✓ All certificates found locally"

echo ""
echo "Configuration:"
echo "  Auth Domain: $KEYCLOAK_DOMAIN"
echo "  Showcase Domain: $APP_DOMAIN"
echo ""

# Create SSL setup script
cat > /tmp/ssl-setup-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Setting up SSL on VPS"
echo "================================================"

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /etc/nginx/ssl
sudo chmod 755 /etc/nginx/ssl

echo "✓ SSL directory created"

echo ""
echo "================================================"
echo "Configuring Nginx for Auth Domain"
echo "================================================"

# Configure auth.vibytes.tech with SSL
sudo tee /etc/nginx/sites-available/keycloak > /dev/null << 'NGINXCONF'
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl;
    server_name KEYCLOAK_DOMAIN;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/auth-vibytes-tech.crt;
    ssl_certificate_key /etc/nginx/ssl/auth-vibytes-tech.key;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # SSL Session
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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

echo "✓ Auth Nginx config created"

echo ""
echo "================================================"
echo "Configuring Nginx for Showcase Domain"
echo "================================================"

# Configure showcase.vibytes.tech with SSL
sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
# HTTP - Redirect to HTTPS
server {
    listen 80;
    server_name APP_DOMAIN;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl;
    server_name APP_DOMAIN;

    # SSL Configuration
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

echo "✓ Showcase Nginx config created"

echo ""
echo "================================================"
echo "Updating Keycloak Configuration for HTTPS"
echo "================================================"

# Update Keycloak config for HTTPS
sudo tee /opt/keycloak/conf/keycloak.conf > /dev/null << KCCONF
# Database
db=postgres
db-username=$KEYCLOAK_DB_USER
db-password=$KEYCLOAK_DB_PASSWORD
db-url=jdbc:postgresql://localhost:5432/$KEYCLOAK_DB_NAME

# HTTP/HTTPS
http-enabled=true
http-port=8080
http-host=0.0.0.0
hostname=$KEYCLOAK_DOMAIN
hostname-strict=true
hostname-strict-https=true

# Proxy (behind Nginx with SSL)
proxy-headers=xforwarded
proxy=edge

# Observability
health-enabled=true
metrics-enabled=true
log-level=info

# Performance
cache=ispn
cache-stack=tcp

# Admin
https-port=8443
KCCONF

sudo chown keycloak:keycloak /opt/keycloak/conf/keycloak.conf

echo "✓ Keycloak config updated for HTTPS"

echo ""
echo "================================================"
echo "Enabling Sites and Testing Nginx"
echo "================================================"

# Enable sites
sudo ln -sf /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/showcase-app /etc/nginx/sites-enabled/

# Test configuration
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "================================================"
echo "Setting Certificate Permissions"
echo "================================================"

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/*.key
sudo chmod 644 /etc/nginx/ssl/*.crt
sudo chown root:root /etc/nginx/ssl/*

echo "✓ Permissions set"

echo ""
echo "================================================"
echo "Restarting Services"
echo "================================================"

# Restart Keycloak (để apply hostname-strict config)
echo "Restarting Keycloak..."
sudo systemctl restart keycloak

# Wait for Keycloak to be ready
echo "Waiting for Keycloak to start (30 seconds)..."
sleep 30

# Reload Nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✓ Services restarted"

echo ""
echo "================================================"
echo "Testing SSL Connections"
echo "================================================"

echo ""
echo "Testing Auth domain (HTTPS)..."
if curl -sSf -k https://localhost:443 -H "Host: $KEYCLOAK_DOMAIN" > /dev/null 2>&1; then
    echo "✓ Auth domain SSL: OK"
else
    echo "⚠ Auth domain SSL: Keycloak might still be starting"
fi

echo ""
echo "Testing Showcase domain (HTTPS)..."
if curl -sSf -k https://localhost:443 -H "Host: $APP_DOMAIN" > /dev/null 2>&1; then
    echo "✓ Showcase domain SSL: OK"
else
    echo "⚠ Showcase domain SSL: Check logs"
fi

echo ""
echo "================================================"
echo "SSL Setup Complete!"
echo "================================================"
echo ""
echo "Your sites are now accessible via HTTPS:"
echo "  🔒 https://$KEYCLOAK_DOMAIN"
echo "  🔒 https://$APP_DOMAIN"
echo ""
echo "HTTP traffic is automatically redirected to HTTPS"
echo ""
echo "Check SSL status:"
echo "  curl -I https://$KEYCLOAK_DOMAIN"
echo "  curl -I https://$APP_DOMAIN"
echo ""
echo "View certificates info:"
echo "  openssl s_client -connect $KEYCLOAK_DOMAIN:443 -servername $KEYCLOAK_DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -dates"
echo "  openssl s_client -connect $APP_DOMAIN:443 -servername $APP_DOMAIN < /dev/null 2>/dev/null | openssl x509 -noout -dates"
echo "================================================"

REMOTESCRIPT

# Upload certificates and execute setup
echo "Uploading certificates to VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    # Upload auth certificates
    echo "Uploading auth certificates..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/auth/private_key_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.key"
    
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/auth/certificate_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.crt"
    
    # Upload showcase certificates
    echo "Uploading showcase certificates..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/showcase/private_key_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.key"
    
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/showcase/certificate_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.crt"
    
    # Move certificates to SSL directory
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo mv /tmp/auth-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/auth-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo mv /tmp/showcase-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/showcase-vibytes-tech.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-setup-script.sh" < /tmp/ssl-setup-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         bash /tmp/ssl-setup-script.sh"
else
    # Using SSH key
    # Upload auth certificates
    echo "Uploading auth certificates..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/auth/private_key_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.key"
    
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/auth/certificate_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.crt"
    
    # Upload showcase certificates
    echo "Uploading showcase certificates..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/showcase/private_key_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.key"
    
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/showcase/certificate_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.crt"
    
    # Move certificates to SSL directory
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo mv /tmp/auth-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/auth-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo mv /tmp/showcase-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/showcase-vibytes-tech.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-setup-script.sh" < /tmp/ssl-setup-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         bash /tmp/ssl-setup-script.sh"
fi

echo ""
echo "================================================"
echo "✅ SSL Setup Completed Successfully!"
echo "================================================"
echo ""
echo "Your applications are now secured with HTTPS:"
echo ""
echo "  🔒 Keycloak: https://$KEYCLOAK_DOMAIN"
echo "  🔒 Showcase: https://$APP_DOMAIN"
echo ""
echo "Test from your browser or:"
echo "  curl -I https://$KEYCLOAK_DOMAIN"
echo "  curl -I https://$APP_DOMAIN"
echo ""

