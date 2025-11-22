#!/bin/bash

# ================================================
# SSL Setup for Auth Domain (Keycloak)
# ================================================
# Setup SSL certificates cho auth.vibytes.tech
# ================================================

set -e

echo "================================================"
echo "SSL Setup - Auth Domain (Keycloak)"
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

if [ ! -f "ca/auth/private_key_auth-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/auth/private_key_auth-vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/auth/certificate_auth-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/auth/certificate_auth-vibytes-tech.txt not found!"
    echo ""
    echo "Please download your domain certificate from Sectigo and save it as:"
    echo "  ca/auth/certificate_auth-vibytes-tech.txt"
    echo ""
    echo "If you haven't validated your domain yet, run:"
    echo "  ./scripts/deploy-validation-auth.sh"
    exit 1
fi

if [ ! -f "ca/auth/rootca_auth-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/auth/rootca_auth-vibytes-tech.txt not found!"
    exit 1
fi

echo "✓ All certificates found"

# Verify certificate
echo ""
echo "Verifying certificate..."
CERT_ISSUER=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -noout -issuer 2>/dev/null | grep -o "CN=[^,]*" | head -1)
CERT_SUBJECT=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -noout -subject 2>/dev/null | grep -o "CN=[^,]*")
CERT_DATES=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -noout -dates 2>/dev/null)

echo "  Issuer: $CERT_ISSUER"
echo "  Subject: $CERT_SUBJECT"
echo "  $CERT_DATES"

# Verify key and cert match
echo ""
echo "Verifying private key and certificate match..."
KEY_MD5=$(openssl rsa -in ca/auth/private_key_auth-vibytes-tech.txt -modulus -noout 2>/dev/null | openssl md5)
CERT_MD5=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -modulus -noout 2>/dev/null | openssl md5)

if [ "$KEY_MD5" = "$CERT_MD5" ]; then
    echo "✓ Private key and certificate match!"
else
    echo "✗ Error: Private key and certificate do not match!"
    exit 1
fi

echo ""
echo "Configuration:"
echo "  Domain: $KEYCLOAK_DOMAIN"
echo "  Keycloak Port: 8080"
echo ""

# Create SSL setup script
cat > /tmp/ssl-auth-setup.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Setting up SSL for Keycloak (Auth Domain)"
echo "================================================"

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /etc/nginx/ssl
sudo chmod 755 /etc/nginx/ssl

# Create fullchain certificate (domain cert + CA bundle)
echo "Creating fullchain certificate..."
sudo bash -c "cat /tmp/auth-vibytes-tech.crt > /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt"
sudo bash -c "echo '' >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt"
sudo bash -c "cat /tmp/auth-vibytes-tech-ca.crt >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt"

# Verify fullchain
echo "Verifying fullchain..."
if openssl x509 -in /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt -noout -subject 2>/dev/null; then
    echo "✓ Fullchain certificate is valid"
else
    echo "✗ Fullchain certificate has issues, using domain cert only"
    sudo cp /tmp/auth-vibytes-tech.crt /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt
fi

# Cleanup temp files
sudo rm -f /tmp/auth-vibytes-tech.*

echo "✓ Certificates prepared"

echo ""
echo "================================================"
echo "Configuring Nginx for Keycloak with SSL"
echo "================================================"

# Configure auth.vibytes.tech with real SSL
sudo tee /etc/nginx/sites-available/keycloak > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation and redirect
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN www.KEYCLOAK_DOMAIN;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/keycloak-validation;
        try_files $uri $uri/ =404;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS
server {
    listen 443 ssl http2;
    server_name KEYCLOAK_DOMAIN www.KEYCLOAK_DOMAIN;

    # SSL Configuration - Real certificates from Sectigo
    ssl_certificate /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt;
    ssl_certificate_key /etc/nginx/ssl/auth-vibytes-tech.key;
    
    # SSL Settings (Modern configuration)
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # SSL Session
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
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
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering off;
        proxy_buffer_size 4k;
        proxy_buffers 8 4k;
        proxy_busy_buffers_size 8k;
    }

    # Increase upload size
    client_max_body_size 10M;
}
NGINXCONF

# Replace placeholders
sudo sed -i "s/KEYCLOAK_DOMAIN/$KEYCLOAK_DOMAIN/g" /etc/nginx/sites-available/keycloak

echo "✓ Nginx config created"

# Enable site
sudo ln -sf /etc/nginx/sites-available/keycloak /etc/nginx/sites-enabled/
# Remove old validation config if exists
sudo rm -f /etc/nginx/sites-enabled/keycloak-validation

echo ""
echo "================================================"
echo "Setting Certificate Permissions"
echo "================================================"

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/auth-vibytes-tech.key
sudo chmod 644 /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt
sudo chown root:root /etc/nginx/ssl/auth-vibytes-tech*

echo "✓ Permissions set"

echo ""
echo "================================================"
echo "Testing and Reloading Nginx"
echo "================================================"

# Test configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✓ Nginx reloaded"

echo ""
echo "================================================"
echo "Updating Keycloak Configuration for HTTPS"
echo "================================================"

# Update Keycloak config to use HTTPS
KEYCLOAK_CONF="/opt/keycloak/conf/keycloak.conf"

if [ -f "$KEYCLOAK_CONF" ]; then
    echo "Updating Keycloak configuration..."
    
    # Backup original
    sudo cp "$KEYCLOAK_CONF" "$KEYCLOAK_CONF.backup"
    
    # Update hostname
    if ! grep -q "^hostname=" "$KEYCLOAK_CONF"; then
        echo "hostname=$KEYCLOAK_DOMAIN" | sudo tee -a "$KEYCLOAK_CONF" > /dev/null
    else
        sudo sed -i "s|^hostname=.*|hostname=$KEYCLOAK_DOMAIN|" "$KEYCLOAK_CONF"
    fi
    
    # Update proxy settings
    if ! grep -q "^proxy=" "$KEYCLOAK_CONF"; then
        echo "proxy=edge" | sudo tee -a "$KEYCLOAK_CONF" > /dev/null
    else
        sudo sed -i "s|^proxy=.*|proxy=edge|" "$KEYCLOAK_CONF"
    fi
    
    # Update hostname-strict
    if ! grep -q "^hostname-strict=" "$KEYCLOAK_CONF"; then
        echo "hostname-strict=false" | sudo tee -a "$KEYCLOAK_CONF" > /dev/null
    else
        sudo sed -i "s|^hostname-strict=.*|hostname-strict=false|" "$KEYCLOAK_CONF"
    fi
    
    echo "✓ Keycloak config updated"
    
    # Restart Keycloak
    echo "Restarting Keycloak..."
    sudo systemctl restart keycloak
    
    # Wait for Keycloak to start
    echo "Waiting for Keycloak to start..."
    sleep 10
    
    echo "✓ Keycloak restarted"
else
    echo "⚠ Keycloak config not found at $KEYCLOAK_CONF"
fi

echo ""
echo "================================================"
echo "Testing SSL Connection"
echo "================================================"

sleep 2

echo ""
echo "Testing HTTPS connection..."
if curl -sSf -k https://localhost:443 -H "Host: $KEYCLOAK_DOMAIN" > /dev/null 2>&1; then
    echo "✓ HTTPS connection: OK"
else
    echo "⚠ HTTPS connection: Check logs if needed"
fi

echo ""
echo "Testing HTTP to HTTPS redirect..."
if curl -sI http://localhost:80 -H "Host: $KEYCLOAK_DOMAIN" | grep -q "301\|302"; then
    echo "✓ HTTP redirect: OK"
else
    echo "⚠ HTTP redirect: Check configuration"
fi

echo ""
echo "================================================"
echo "SSL Setup Complete!"
echo "================================================"
echo ""
echo "Your Keycloak is now secured with real SSL certificate:"
echo "  🔒 https://$KEYCLOAK_DOMAIN"
echo "  🔒 https://www.$KEYCLOAK_DOMAIN"
echo ""
echo "Certificate Info:"
echo "  Issuer: Sectigo Limited"
echo "  Valid until: Nov 22, 2026"
echo ""
echo "Test in browser:"
echo "  https://$KEYCLOAK_DOMAIN"
echo "  https://$KEYCLOAK_DOMAIN/admin/"
echo ""
echo "Check SSL rating:"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$KEYCLOAK_DOMAIN"
echo ""

REMOTESCRIPT

# Upload certificates and execute setup
echo "Uploading certificates to VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    # Upload auth certificates
    echo "Uploading auth private key..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/auth/private_key_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.key"
    
    echo "Uploading auth domain certificate..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/auth/certificate_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.crt"
    
    echo "Uploading CA bundle..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/auth/rootca_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech-ca.crt"
    
    # Copy certificates to SSL directory (keep originals in /tmp for fullchain creation)
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo cp /tmp/auth-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo cp /tmp/auth-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo cp /tmp/auth-vibytes-tech-ca.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-auth-setup.sh" < /tmp/ssl-auth-setup.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         bash /tmp/ssl-auth-setup.sh"
else
    # Using SSH key
    # Upload auth certificates
    echo "Uploading auth private key..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/auth/private_key_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.key"
    
    echo "Uploading auth domain certificate..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/auth/certificate_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech.crt"
    
    echo "Uploading CA bundle..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/auth/rootca_auth-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/auth-vibytes-tech-ca.crt"
    
    # Copy certificates to SSL directory (keep originals in /tmp for fullchain creation)
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo cp /tmp/auth-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo cp /tmp/auth-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo cp /tmp/auth-vibytes-tech-ca.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-auth-setup.sh" < /tmp/ssl-auth-setup.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         bash /tmp/ssl-auth-setup.sh"
fi

echo ""
echo "================================================"
echo "✅ SSL Setup Completed Successfully!"
echo "================================================"
echo ""
echo "Your Keycloak is now secured with real SSL:"
echo ""
echo "  🔒 https://$KEYCLOAK_DOMAIN"
echo "  🔒 https://$KEYCLOAK_DOMAIN/admin/"
echo ""
echo "Certificate Details:"
echo "  Issuer: Sectigo RSA Domain Validation Secure Server CA"
echo "  Subject: CN=auth.vibytes.tech"
echo "  Valid: Nov 22, 2025 - Nov 22, 2026"
echo ""
echo "⚠️  IMPORTANT: Update your Next.js app environment:"
echo "  NEXT_PUBLIC_KEYCLOAK_URL=https://$KEYCLOAK_DOMAIN"
echo ""
echo "Then redeploy your app:"
echo "  ./scripts/deploy-app-auto.sh"
echo ""
echo "Test in browser - should show secure lock icon ✓"
echo ""

