#!/bin/bash

# ================================================
# Fix Nginx Config for Validation
# ================================================

set -e

echo "================================================"
echo "Fixing Nginx Config for Validation"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "Disabling conflicting keycloak config..."
sudo rm -f /etc/nginx/sites-enabled/keycloak

echo "✓ Disabled old keycloak config"

echo ""
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✓ Nginx reloaded"

echo ""
echo "Testing validation file access..."
sleep 2
if curl -sf http://localhost/.well-known/pki-validation/5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt > /dev/null; then
    echo "✓ Validation file is accessible!"
    echo ""
    echo "Content:"
    curl -s http://localhost/.well-known/pki-validation/5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt
else
    echo "✗ Still not accessible"
fi

ENDSSH
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "Disabling conflicting keycloak config..."
sudo rm -f /etc/nginx/sites-enabled/keycloak

echo "✓ Disabled old keycloak config"

echo ""
echo "Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "✓ Nginx reloaded"

echo ""
echo "Testing validation file access..."
sleep 2
if curl -sf http://localhost/.well-known/pki-validation/5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt > /dev/null; then
    echo "✓ Validation file is accessible!"
    echo ""
    echo "Content:"
    curl -s http://localhost/.well-known/pki-validation/5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt
else
    echo "✗ Still not accessible"
fi

ENDSSH
fi

echo ""
echo "================================================"
echo "✅ Done!"
echo "================================================"
echo ""
echo "Validation URL is now accessible at:"
echo "  http://auth.vibytes.tech/.well-known/pki-validation/5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt"
echo ""
echo "Please go to Sectigo and click 'Validate Domain' button"
echo ""

