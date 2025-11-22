#!/bin/bash

# ================================================
# Quick SSL Validation File Deployment
# ================================================
# Usage: ./deploy-ssl-validation-file.sh <filename> <content>
# Example: ./deploy-ssl-validation-file.sh DD420E628EDFB75596E4438A876F43EB.txt "comodoca.com..."
# ================================================

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <filename> <content>"
    echo "Example: $0 DD420E628EDFB75596E4438A876F43EB.txt \"validation content here\""
    exit 1
fi

VALIDATION_FILE="$1"
VALIDATION_CONTENT="$2"

echo "================================================"
echo "SSL Domain Validation - Quick Deploy"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

echo ""
echo "Deploying validation file:"
echo "  File: $VALIDATION_FILE"
echo "  Domain: $APP_DOMAIN"
echo "  URL: http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

# Create directories and file on VPS
if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" << ENDSSH
set -e

# Create directory
sudo mkdir -p /var/www/showcase-app/public/.well-known/pki-validation
sudo chmod -R 755 /var/www/showcase-app/public/.well-known

# Create validation file
echo "$VALIDATION_CONTENT" | sudo tee /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE > /dev/null
sudo chmod 644 /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE

# Update Nginx to allow .well-known access via HTTP
sudo sed -i '/listen 80;/a\    \\n    # SSL validation\\n    location /.well-known/ {\\n        root /var/www/showcase-app/public;\\n        allow all;\\n    }' /etc/nginx/sites-available/showcase-app || true

# Reload Nginx
sudo nginx -t && sudo systemctl reload nginx

echo ""
echo "✓ Validation file deployed!"
echo ""
echo "Testing access..."
curl -sI http://localhost/.well-known/pki-validation/$VALIDATION_FILE | head -5

echo ""
echo "File content:"
cat /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE

ENDSSH
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" << ENDSSH
set -e

# Create directory
sudo mkdir -p /var/www/showcase-app/public/.well-known/pki-validation
sudo chmod -R 755 /var/www/showcase-app/public/.well-known

# Create validation file
echo "$VALIDATION_CONTENT" | sudo tee /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE > /dev/null
sudo chmod 644 /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE

# Update Nginx to allow .well-known access via HTTP
sudo sed -i '/listen 80;/a\    \\n    # SSL validation\\n    location /.well-known/ {\\n        root /var/www/showcase-app/public;\\n        allow all;\\n    }' /etc/nginx/sites-available/showcase-app || true

# Reload Nginx
sudo nginx -t && sudo systemctl reload nginx

echo ""
echo "✓ Validation file deployed!"
echo ""
echo "Testing access..."
curl -sI http://localhost/.well-known/pki-validation/$VALIDATION_FILE | head -5

echo ""
echo "File content:"
cat /var/www/showcase-app/public/.well-known/pki-validation/$VALIDATION_FILE

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
echo "  2. Click 'Validate' or 'Verify Domain'"
echo "  3. Wait for validation (usually 5-30 minutes)"
echo "  4. Download issued certificates"
echo "  5. Replace them in ca/showcase/ directory"
echo ""
echo "Test now:"
echo "  curl http://$APP_DOMAIN/.well-known/pki-validation/$VALIDATION_FILE"
echo ""

