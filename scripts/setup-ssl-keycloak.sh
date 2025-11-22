#!/bin/bash

# ================================================
# SSL Setup Script for Keycloak (auth.vibytes.tech)
# ================================================
# Thiết lập HTTPS cho Keycloak sử dụng SSL certificate
# ================================================

set -e

echo "================================================"
echo "SSL Setup for Keycloak"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

# Check if certificate files exist
if [ ! -f "ca/private_key_vibytes-tech.txt" ]; then
    echo "✗ Error: ca/private_key_vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/rootca_vibytes-tech.txt" ]; then
    echo "✗ Error: ca/rootca_vibytes-tech.txt not found!"
    exit 1
fi

echo ""
echo "SSL Configuration:"
echo "-----------------"
echo "Keycloak Domain: $KEYCLOAK_DOMAIN"
echo "VPS: $VPS_USER@$VPS_HOST"
echo ""

# Create temp directory for processed certificates
TEMP_CERT_DIR="/tmp/ssl-keycloak-$$"
mkdir -p "$TEMP_CERT_DIR"

# Copy and rename certificates
cp ca/private_key_vibytes-tech.txt "$TEMP_CERT_DIR/vibytes-tech.key"
cp ca/rootca_vibytes-tech.txt "$TEMP_CERT_DIR/vibytes-tech-ca.crt"

# Check if domain certificate exists
if [ -f "ca/certificate_vibytes-tech.txt" ]; then
    echo "✓ Found domain certificate"
    cp ca/certificate_vibytes-tech.txt "$TEMP_CERT_DIR/vibytes-tech.crt"
    HAS_DOMAIN_CERT=true
else
    echo "⚠ Domain certificate not found, will use CA certificate"
    HAS_DOMAIN_CERT=false
fi

echo ""
echo "================================================"
echo "Uploading Certificates to VPS"
echo "================================================"

# Create SSL directory on VPS and upload certificates
if [ -n "$VPS_PASSWORD" ]; then
    # Create SSL directory
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl"
    
    # Upload private key
    echo "Uploading private key..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        "$TEMP_CERT_DIR/vibytes-tech.key" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Upload CA certificate
    echo "Uploading CA certificate..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        "$TEMP_CERT_DIR/vibytes-tech-ca.crt" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Upload domain certificate if exists
    if [ "$HAS_DOMAIN_CERT" = true ]; then
        echo "Uploading domain certificate..."
        sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
            "$TEMP_CERT_DIR/vibytes-tech.crt" \
            "$VPS_USER@$VPS_HOST:/tmp/"
    fi
    
    # Move certificates to SSL directory
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mv /tmp/vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/vibytes-tech-ca.crt /etc/nginx/ssl/ && \
         $([ "$HAS_DOMAIN_CERT" = true ] && echo "sudo mv /tmp/vibytes-tech.crt /etc/nginx/ssl/ &&") \
         sudo chmod 600 /etc/nginx/ssl/vibytes-tech.key && \
         sudo chmod 644 /etc/nginx/ssl/vibytes-tech-ca.crt && \
         $([ "$HAS_DOMAIN_CERT" = true ] && echo "sudo chmod 644 /etc/nginx/ssl/vibytes-tech.crt &&") \
         sudo chown root:root /etc/nginx/ssl/*"
else
    # Using SSH key
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl"
    
    echo "Uploading private key..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        "$TEMP_CERT_DIR/vibytes-tech.key" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    echo "Uploading CA certificate..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        "$TEMP_CERT_DIR/vibytes-tech-ca.crt" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    if [ "$HAS_DOMAIN_CERT" = true ]; then
        echo "Uploading domain certificate..."
        scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
            "$TEMP_CERT_DIR/vibytes-tech.crt" \
            "$VPS_USER@$VPS_HOST:/tmp/"
    fi
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mv /tmp/vibytes-tech.key /etc/nginx/ssl/ && \
         sudo mv /tmp/vibytes-tech-ca.crt /etc/nginx/ssl/ && \
         $([ "$HAS_DOMAIN_CERT" = true ] && echo "sudo mv /tmp/vibytes-tech.crt /etc/nginx/ssl/ &&") \
         sudo chmod 600 /etc/nginx/ssl/vibytes-tech.key && \
         sudo chmod 644 /etc/nginx/ssl/vibytes-tech-ca.crt && \
         $([ "$HAS_DOMAIN_CERT" = true ] && echo "sudo chmod 644 /etc/nginx/ssl/vibytes-tech.crt &&") \
         sudo chown root:root /etc/nginx/ssl/*"
fi

echo "✓ Certificates uploaded"

# Cleanup local temp directory
rm -rf "$TEMP_CERT_DIR"

echo ""
echo "================================================"
echo "Configuring Nginx with SSL"
echo "================================================"

# Create Nginx SSL configuration script
cat > /tmp/nginx-ssl-config.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

# Check if domain certificate exists, if not create full chain
if [ ! -f /etc/nginx/ssl/vibytes-tech.crt ]; then
    echo "Creating certificate chain..."
    sudo cp /etc/nginx/ssl/vibytes-tech-ca.crt /etc/nginx/ssl/vibytes-tech.crt
fi

# Create full chain if needed (combine domain cert + CA)
if [ -f /etc/nginx/ssl/vibytes-tech.crt ] && [ -f /etc/nginx/ssl/vibytes-tech-ca.crt ]; then
    echo "Creating full certificate chain..."
    sudo cat /etc/nginx/ssl/vibytes-tech.crt /etc/nginx/ssl/vibytes-tech-ca.crt | \
        sudo tee /etc/nginx/ssl/vibytes-tech-fullchain.crt > /dev/null
fi

# Backup existing config
if [ -f /etc/nginx/sites-available/keycloak ]; then
    sudo cp /etc/nginx/sites-available/keycloak /etc/nginx/sites-available/keycloak.backup
fi

# Create Nginx configuration with SSL
sudo tee /etc/nginx/sites-available/keycloak > /dev/null << 'NGINXCONF'
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN;
    
    # Redirect all HTTP traffic to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name KEYCLOAK_DOMAIN;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/vibytes-tech-fullchain.crt;
    ssl_certificate_key /etc/nginx/ssl/vibytes-tech.key;

    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    # SSL Session Settings
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/nginx/ssl/vibytes-tech-ca.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;

    # Security Headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Proxy to Keycloak
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port 443;
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

    # Logging
    access_log /var/log/nginx/keycloak-access.log;
    error_log /var/log/nginx/keycloak-error.log;
}
NGINXCONF

# Replace domain placeholder
sudo sed -i "s/KEYCLOAK_DOMAIN/$KEYCLOAK_DOMAIN/g" /etc/nginx/sites-available/keycloak

# Enable site
sudo ln -sf /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx configuration is valid"
    
    # Reload Nginx
    echo "Reloading Nginx..."
    sudo systemctl reload nginx
    
    echo "✓ Nginx reloaded successfully"
else
    echo "✗ Nginx configuration test failed"
    echo "Restoring backup..."
    if [ -f /etc/nginx/sites-available/keycloak.backup ]; then
        sudo mv /etc/nginx/sites-available/keycloak.backup /etc/nginx/sites-available/keycloak
        sudo systemctl reload nginx
    fi
    exit 1
fi

REMOTESCRIPT

# Execute on VPS
echo "Executing SSL configuration on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-ssl-config.sh" < /tmp/nginx-ssl-config.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         bash /tmp/nginx-ssl-config.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/nginx-ssl-config.sh" < /tmp/nginx-ssl-config.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         bash /tmp/nginx-ssl-config.sh"
fi

echo ""
echo "================================================"
echo "Updating Keycloak Configuration for HTTPS"
echo "================================================"

# Update Keycloak configuration for HTTPS
cat > /tmp/update-keycloak-https.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

# Backup existing configuration
sudo cp $KEYCLOAK_INSTALL_PATH/conf/keycloak.conf $KEYCLOAK_INSTALL_PATH/conf/keycloak.conf.backup

# Update Keycloak configuration
sudo tee $KEYCLOAK_INSTALL_PATH/conf/keycloak.conf > /dev/null << KCCONF
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
hostname-strict=false
hostname-strict-https=false

# Proxy - Important for HTTPS
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

echo "✓ Keycloak configuration updated"

# Rebuild Keycloak
echo "Rebuilding Keycloak..."
cd $KEYCLOAK_INSTALL_PATH
sudo -u keycloak \
    KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN \
    KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
    JAVA_OPTS="-Xms512m -Xmx1536m" \
    bin/kc.sh build

echo "✓ Keycloak rebuilt"

# Restart Keycloak
echo "Restarting Keycloak..."
sudo systemctl restart keycloak

echo "Waiting for Keycloak to start..."
sleep 30

# Check Keycloak status
sudo systemctl status keycloak --no-pager || true

echo "✓ Keycloak restarted"

REMOTESCRIPT

# Execute Keycloak update on VPS
echo "Updating Keycloak configuration..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/update-keycloak-https.sh" < /tmp/update-keycloak-https.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         bash /tmp/update-keycloak-https.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/update-keycloak-https.sh" < /tmp/update-keycloak-https.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         bash /tmp/update-keycloak-https.sh"
fi

echo ""
echo "================================================"
echo "Testing HTTPS Connection"
echo "================================================"

echo "Waiting for services to stabilize..."
sleep 10

echo "Testing HTTPS connection to $KEYCLOAK_DOMAIN..."
if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "curl -sI https://$KEYCLOAK_DOMAIN/ | head -n 5 || echo 'Warning: HTTPS test failed'"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "curl -sI https://$KEYCLOAK_DOMAIN/ | head -n 5 || echo 'Warning: HTTPS test failed'"
fi

echo ""
echo "================================================"
echo "SSL Setup Complete!"
echo "================================================"
echo ""
echo "SSL Information:"
echo "  Domain: $KEYCLOAK_DOMAIN"
echo "  Certificate: /etc/nginx/ssl/vibytes-tech-fullchain.crt"
echo "  Private Key: /etc/nginx/ssl/vibytes-tech.key"
echo "  CA Bundle: /etc/nginx/ssl/vibytes-tech-ca.crt"
echo ""
echo "Access Keycloak at:"
echo "  https://$KEYCLOAK_DOMAIN"
echo ""
echo "Admin Console:"
echo "  https://$KEYCLOAK_DOMAIN/admin"
echo "  Username: $KEYCLOAK_ADMIN"
echo ""
echo "Useful Commands:"
echo "  # Check Nginx SSL"
echo "  sudo nginx -t"
echo "  sudo systemctl status nginx"
echo ""
echo "  # Check Keycloak"
echo "  sudo systemctl status keycloak"
echo "  sudo journalctl -u keycloak -f"
echo ""
echo "  # View SSL certificates"
echo "  sudo ls -la /etc/nginx/ssl/"
echo "  openssl x509 -in /etc/nginx/ssl/vibytes-tech-fullchain.crt -text -noout"
echo ""
echo "  # Test SSL from external"
echo "  curl -I https://$KEYCLOAK_DOMAIN"
echo "  openssl s_client -connect $KEYCLOAK_DOMAIN:443 -servername $KEYCLOAK_DOMAIN"
echo "================================================"
echo ""

# Cleanup
rm -f /tmp/nginx-ssl-config.sh /tmp/update-keycloak-https.sh

echo "✓ All done! Your Keycloak is now secured with HTTPS"
echo ""

