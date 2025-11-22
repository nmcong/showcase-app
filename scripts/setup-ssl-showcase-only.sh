#!/bin/bash

# ================================================
# SSL Setup for Showcase Domain Only
# ================================================
# Setup SSL certificates cho showcase.vibytes.tech
# ================================================

set -e

echo "================================================"
echo "SSL Setup - Showcase Domain Only"
echo "================================================"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "✗ Error: .env not found!"
    exit 1
fi

# Validate certificates exist
echo ""
echo "Validating local certificates..."

if [ ! -f "ca/showcase/private_key_showcase-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/showcase/private_key_showcase-vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/showcase/certificate_showcase-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/showcase/certificate_showcase-vibytes-tech.txt not found!"
    exit 1
fi

if [ ! -f "ca/showcase/rootca_showcase-vibytes-tech.txt" ]; then
    echo "✗ Error: ca/showcase/rootca_showcase-vibytes-tech.txt not found!"
    exit 1
fi

echo "✓ All certificates found"

# Verify certificate
echo ""
echo "Verifying certificate..."
CERT_ISSUER=$(openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -noout -issuer 2>/dev/null | grep -o "CN=[^,]*" | head -1)
CERT_SUBJECT=$(openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -noout -subject 2>/dev/null | grep -o "CN=[^,]*")
CERT_DATES=$(openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -noout -dates 2>/dev/null)

echo "  Issuer: $CERT_ISSUER"
echo "  Subject: $CERT_SUBJECT"
echo "  $CERT_DATES"

# Verify key and cert match
echo ""
echo "Verifying private key and certificate match..."
KEY_MD5=$(openssl rsa -in ca/showcase/private_key_showcase-vibytes-tech.txt -modulus -noout 2>/dev/null | openssl md5)
CERT_MD5=$(openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -modulus -noout 2>/dev/null | openssl md5)

if [ "$KEY_MD5" = "$CERT_MD5" ]; then
    echo "✓ Private key and certificate match!"
else
    echo "✗ Error: Private key and certificate do not match!"
    exit 1
fi

echo ""
echo "Configuration:"
echo "  Domain: $APP_DOMAIN"
echo "  Port: $APP_PORT"
echo ""

# Create SSL setup script
cat > /tmp/ssl-showcase-setup.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Setting up SSL for Showcase"
echo "================================================"

# Create SSL directory
echo "Creating SSL directory..."
sudo mkdir -p /etc/nginx/ssl
sudo chmod 755 /etc/nginx/ssl

# Create fullchain certificate (domain cert + CA bundle)
echo "Creating fullchain certificate..."
sudo bash -c "cat /tmp/showcase-vibytes-tech.crt > /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt"
sudo bash -c "echo '' >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt"
sudo bash -c "cat /tmp/showcase-vibytes-tech-ca.crt >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt"

# Verify fullchain
echo "Verifying fullchain..."
if openssl x509 -in /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt -noout -subject 2>/dev/null; then
    echo "✓ Fullchain certificate is valid"
else
    echo "✗ Fullchain certificate has issues, using domain cert only"
    sudo cp /tmp/showcase-vibytes-tech.crt /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt
fi

# Cleanup temp files
sudo rm -f /tmp/showcase-vibytes-tech.*

echo "✓ Certificates prepared"

echo ""
echo "================================================"
echo "Configuring Nginx for Showcase with SSL"
echo "================================================"

# Configure showcase.vibytes.tech with real SSL
sudo tee /etc/nginx/sites-available/showcase-app > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation and redirect
server {
    listen 80;
    server_name APP_DOMAIN www.APP_DOMAIN;
    
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
    listen 443 ssl http2;
    server_name APP_DOMAIN www.APP_DOMAIN;

    # SSL Configuration - Real certificates from Sectigo
    ssl_certificate /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt;
    ssl_certificate_key /etc/nginx/ssl/showcase-vibytes-tech.key;
    
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
    ssl_trusted_certificate /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

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
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Increase upload size for 3D models
    client_max_body_size 100M;
}
NGINXCONF

# Replace placeholders
sudo sed -i "s/APP_DOMAIN/$APP_DOMAIN/g" /etc/nginx/sites-available/showcase-app
sudo sed -i "s/APP_PORT/$APP_PORT/g" /etc/nginx/sites-available/showcase-app

echo "✓ Nginx config created"

# Enable site
sudo ln -sf /etc/nginx/sites-available/showcase-app /etc/nginx/sites-enabled/

echo ""
echo "================================================"
echo "Setting Certificate Permissions"
echo "================================================"

# Set proper permissions
sudo chmod 600 /etc/nginx/ssl/showcase-vibytes-tech.key
sudo chmod 644 /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt
sudo chown root:root /etc/nginx/ssl/showcase-vibytes-tech*

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
echo "Testing SSL Connection"
echo "================================================"

sleep 2

echo ""
echo "Testing HTTPS connection..."
if curl -sSf -k https://localhost:443 -H "Host: $APP_DOMAIN" > /dev/null 2>&1; then
    echo "✓ HTTPS connection: OK"
else
    echo "⚠ HTTPS connection: Check logs if needed"
fi

echo ""
echo "Testing HTTP to HTTPS redirect..."
if curl -sI http://localhost:80 -H "Host: $APP_DOMAIN" | grep -q "301\|302"; then
    echo "✓ HTTP redirect: OK"
else
    echo "⚠ HTTP redirect: Check configuration"
fi

echo ""
echo "================================================"
echo "SSL Setup Complete!"
echo "================================================"
echo ""
echo "Your site is now secured with real SSL certificate:"
echo "  🔒 https://$APP_DOMAIN"
echo "  🔒 https://www.$APP_DOMAIN"
echo ""
echo "Certificate Info:"
echo "  Issuer: Sectigo Limited"
echo "  Valid until: Nov 22, 2026"
echo ""
echo "Test in browser:"
echo "  https://$APP_DOMAIN"
echo ""
echo "Check SSL rating:"
echo "  https://www.ssllabs.com/ssltest/analyze.html?d=$APP_DOMAIN"
echo ""

REMOTESCRIPT

# Upload certificates and execute setup
echo "Uploading certificates to VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    # Upload showcase certificates
    echo "Uploading showcase private key..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/showcase/private_key_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.key"
    
    echo "Uploading showcase domain certificate..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/showcase/certificate_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.crt"
    
    echo "Uploading CA bundle..."
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        ca/showcase/rootca_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech-ca.crt"
    
    # Copy certificates to SSL directory (keep originals in /tmp for fullchain creation)
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo cp /tmp/showcase-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo cp /tmp/showcase-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo cp /tmp/showcase-vibytes-tech-ca.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-showcase-setup.sh" < /tmp/ssl-showcase-setup.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         bash /tmp/ssl-showcase-setup.sh"
else
    # Using SSH key
    # Upload showcase certificates
    echo "Uploading showcase private key..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/showcase/private_key_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.key"
    
    echo "Uploading showcase domain certificate..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/showcase/certificate_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech.crt"
    
    echo "Uploading CA bundle..."
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        ca/showcase/rootca_showcase-vibytes-tech.txt \
        "$VPS_USER@$VPS_HOST:/tmp/showcase-vibytes-tech-ca.crt"
    
    # Copy certificates to SSL directory (keep originals in /tmp for fullchain creation)
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "sudo mkdir -p /etc/nginx/ssl && \
         sudo cp /tmp/showcase-vibytes-tech.key /etc/nginx/ssl/ && \
         sudo cp /tmp/showcase-vibytes-tech.crt /etc/nginx/ssl/ && \
         sudo cp /tmp/showcase-vibytes-tech-ca.crt /etc/nginx/ssl/"
    
    echo "✓ Certificates uploaded"
    
    # Upload and execute setup script
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/ssl-showcase-setup.sh" < /tmp/ssl-showcase-setup.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         bash /tmp/ssl-showcase-setup.sh"
fi

echo ""
echo "================================================"
echo "✅ SSL Setup Completed Successfully!"
echo "================================================"
echo ""
echo "Your Showcase application is now secured with real SSL:"
echo ""
echo "  🔒 https://$APP_DOMAIN"
echo ""
echo "Certificate Details:"
echo "  Issuer: Sectigo RSA Domain Validation Secure Server CA"
echo "  Subject: CN=showcase.vibytes.tech"
echo "  Valid: Nov 22, 2025 - Nov 22, 2026"
echo "  Coverage: showcase.vibytes.tech, www.showcase.vibytes.tech"
echo ""
echo "Test in browser - should show secure lock icon ✓"
echo ""

