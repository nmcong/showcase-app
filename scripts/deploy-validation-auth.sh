#!/bin/bash

# ================================================
# Deploy SSL Validation File for Auth Domain
# ================================================

set -e

echo "================================================"
echo "Deploying SSL Validation File for Auth Domain"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

VALIDATION_FILE="5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt"

if [ ! -f "ca/auth/$VALIDATION_FILE" ]; then
    echo "✗ Error: ca/auth/$VALIDATION_FILE not found!"
    exit 1
fi

echo ""
echo "Found validation file: ca/auth/$VALIDATION_FILE"
echo "Deploying to: http://$KEYCLOAK_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

# Upload and deploy
if [ -n "$VPS_PASSWORD" ]; then
    # Upload file
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        "ca/auth/$VALIDATION_FILE" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    # Deploy on VPS
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export VALIDATION_FILE='$VALIDATION_FILE' && \
         bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "Creating directory structure..."
sudo mkdir -p /var/www/keycloak-validation/.well-known/pki-validation
sudo chmod -R 755 /var/www/keycloak-validation/.well-known

echo "Moving validation file..."
sudo mv /tmp/$VALIDATION_FILE /var/www/keycloak-validation/.well-known/pki-validation/
sudo chmod 644 /var/www/keycloak-validation/.well-known/pki-validation/$VALIDATION_FILE

echo "✓ File deployed"

echo ""
echo "Updating Nginx configuration for validation..."

# Create or update Nginx config for auth domain validation
sudo tee /etc/nginx/sites-available/keycloak-validation > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation only
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/keycloak-validation;
        try_files $uri $uri/ =404;
    }
    
    # Proxy everything else to Keycloak
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINXCONF

# Replace placeholder
sudo sed -i "s/KEYCLOAK_DOMAIN/$KEYCLOAK_DOMAIN/g" /etc/nginx/sites-available/keycloak-validation

echo "✓ Nginx config updated"

# Enable site
sudo ln -sf /etc/nginx/sites-available/keycloak-validation /etc/nginx/sites-enabled/

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
if curl -sf http://localhost/.well-known/pki-validation/$VALIDATION_FILE > /dev/null; then
    echo "✓ File is accessible!"
    echo ""
    echo "File content:"
    curl -s http://localhost/.well-known/pki-validation/$VALIDATION_FILE
else
    echo "✗ File is not accessible"
    echo ""
    echo "Checking file existence..."
    ls -la /var/www/keycloak-validation/.well-known/pki-validation/
fi

ENDSSH
else
    # Using SSH key
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        "ca/auth/$VALIDATION_FILE" \
        "$VPS_USER@$VPS_HOST:/tmp/"
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export VALIDATION_FILE='$VALIDATION_FILE' && \
         bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "Creating directory structure..."
sudo mkdir -p /var/www/keycloak-validation/.well-known/pki-validation
sudo chmod -R 755 /var/www/keycloak-validation/.well-known

echo "Moving validation file..."
sudo mv /tmp/$VALIDATION_FILE /var/www/keycloak-validation/.well-known/pki-validation/
sudo chmod 644 /var/www/keycloak-validation/.well-known/pki-validation/$VALIDATION_FILE

echo "✓ File deployed"

echo ""
echo "Updating Nginx configuration for validation..."

# Create or update Nginx config for auth domain validation
sudo tee /etc/nginx/sites-available/keycloak-validation > /dev/null << 'NGINXCONF'
# HTTP - For SSL validation only
server {
    listen 80;
    server_name KEYCLOAK_DOMAIN;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/keycloak-validation;
        try_files $uri $uri/ =404;
    }
    
    # Proxy everything else to Keycloak
    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
NGINXCONF

# Replace placeholder
sudo sed -i "s/KEYCLOAK_DOMAIN/$KEYCLOAK_DOMAIN/g" /etc/nginx/sites-available/keycloak-validation

echo "✓ Nginx config updated"

# Enable site
sudo ln -sf /etc/nginx/sites-available/keycloak-validation /etc/nginx/sites-enabled/

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
if curl -sf http://localhost/.well-known/pki-validation/$VALIDATION_FILE > /dev/null; then
    echo "✓ File is accessible!"
    echo ""
    echo "File content:"
    curl -s http://localhost/.well-known/pki-validation/$VALIDATION_FILE
else
    echo "✗ File is not accessible"
    echo ""
    echo "Checking file existence..."
    ls -la /var/www/keycloak-validation/.well-known/pki-validation/
fi

ENDSSH
fi

echo ""
echo "================================================"
echo "✅ Validation File Deployment Complete!"
echo "================================================"
echo ""
echo "Validation URL:"
echo "  http://$KEYCLOAK_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""
echo "Next steps:"
echo "  1. Go to your SSL provider's website (Sectigo)"
echo "  2. Click 'Validate' or 'Check Domain' button"
echo "  3. Wait for validation (5-30 minutes)"
echo "  4. Download issued certificate when ready"
echo "  5. Save as: ca/auth/certificate_auth-vibytes-tech.txt"
echo "  6. Run: ./scripts/setup-ssl-auth.sh"
echo ""
echo "Test URL in browser:"
echo "  http://auth.vibytes.tech/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

