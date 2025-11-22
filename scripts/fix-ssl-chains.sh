#!/bin/bash

# ================================================
# Fix SSL Certificate Chains for Both Domains
# ================================================
# Recreate fullchain certificates với format đúng
# ================================================

set -e

echo "================================================"
echo "Fix SSL Certificate Chains"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

echo ""
echo "This will fix SSL certificate chains for:"
echo "  - showcase.vibytes.tech"
echo "  - auth.vibytes.tech"
echo ""
echo "Issue: Fullchain certificates missing blank lines between certs"
echo "Fix: Recreate fullchain with proper format"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Execute fix on VPS
if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "================================================"
echo "Fixing Showcase Domain"
echo "================================================"

echo "Backing up existing fullchain..."
sudo cp /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt \
        /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt.backup.$(date +%Y%m%d-%H%M%S)

echo "Recreating fullchain..."
sudo bash -c 'cat /etc/nginx/ssl/showcase-vibytes-tech.crt > /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'
sudo bash -c 'echo "" >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'
sudo bash -c 'cat /etc/nginx/ssl/showcase-vibytes-tech-ca.crt >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'

echo "Verifying..."
CERT_COUNT=$(openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt | openssl pkcs7 -print_certs -noout | grep -c subject)
echo "✓ Showcase fullchain contains $CERT_COUNT certificates"

echo ""
echo "================================================"
echo "Fixing Auth Domain"
echo "================================================"

echo "Backing up existing fullchain..."
sudo cp /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt \
        /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt.backup.$(date +%Y%m%d-%H%M%S)

echo "Recreating fullchain..."
sudo bash -c 'cat /etc/nginx/ssl/auth-vibytes-tech.crt > /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'
sudo bash -c 'echo "" >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'
sudo bash -c 'cat /etc/nginx/ssl/auth-vibytes-tech-ca.crt >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'

echo "Verifying..."
CERT_COUNT=$(openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt | openssl pkcs7 -print_certs -noout | grep -c subject)
echo "✓ Auth fullchain contains $CERT_COUNT certificates"

echo ""
echo "================================================"
echo "Reloading Nginx"
echo "================================================"

sudo nginx -t && sudo systemctl reload nginx
echo "✓ Nginx reloaded"

echo ""
echo "================================================"
echo "Testing Certificate Chains"
echo "================================================"

echo ""
echo "Showcase domain:"
openssl s_client -connect localhost:443 -servername showcase.vibytes.tech < /dev/null 2>/dev/null | grep -A3 "Certificate chain" | grep "s:" | wc -l | xargs echo "  Certificates in chain:"

echo ""
echo "Auth domain:"
openssl s_client -connect localhost:443 -servername auth.vibytes.tech < /dev/null 2>/dev/null | grep -A3 "Certificate chain" | grep "s:" | wc -l | xargs echo "  Certificates in chain:"

echo ""
echo "================================================"
echo "✅ Fix Complete!"
echo "================================================"
echo ""
echo "Both domains now have proper certificate chains."
echo ""
echo "Please test in browser:"
echo "  - https://showcase.vibytes.tech"
echo "  - https://auth.vibytes.tech"
echo ""
echo "Should show 🔒 secure lock icon"
echo ""

ENDSSH
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "================================================"
echo "Fixing Showcase Domain"
echo "================================================"

echo "Backing up existing fullchain..."
sudo cp /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt \
        /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt.backup.$(date +%Y%m%d-%H%M%S)

echo "Recreating fullchain..."
sudo bash -c 'cat /etc/nginx/ssl/showcase-vibytes-tech.crt > /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'
sudo bash -c 'echo "" >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'
sudo bash -c 'cat /etc/nginx/ssl/showcase-vibytes-tech-ca.crt >> /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt'

echo "Verifying..."
CERT_COUNT=$(openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/showcase-vibytes-tech-fullchain.crt | openssl pkcs7 -print_certs -noout | grep -c subject)
echo "✓ Showcase fullchain contains $CERT_COUNT certificates"

echo ""
echo "================================================"
echo "Fixing Auth Domain"
echo "================================================"

echo "Backing up existing fullchain..."
sudo cp /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt \
        /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt.backup.$(date +%Y%m%d-%H%M%S)

echo "Recreating fullchain..."
sudo bash -c 'cat /etc/nginx/ssl/auth-vibytes-tech.crt > /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'
sudo bash -c 'echo "" >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'
sudo bash -c 'cat /etc/nginx/ssl/auth-vibytes-tech-ca.crt >> /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'

echo "Verifying..."
CERT_COUNT=$(openssl crl2pkcs7 -nocrl -certfile /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt | openssl pkcs7 -print_certs -noout | grep -c subject)
echo "✓ Auth fullchain contains $CERT_COUNT certificates"

echo ""
echo "================================================"
echo "Reloading Nginx"
echo "================================================"

sudo nginx -t && sudo systemctl reload nginx
echo "✓ Nginx reloaded"

echo ""
echo "================================================"
echo "Testing Certificate Chains"
echo "================================================"

echo ""
echo "Showcase domain:"
openssl s_client -connect localhost:443 -servername showcase.vibytes.tech < /dev/null 2>/dev/null | grep -A3 "Certificate chain" | grep "s:" | wc -l | xargs echo "  Certificates in chain:"

echo ""
echo "Auth domain:"
openssl s_client -connect localhost:443 -servername auth.vibytes.tech < /dev/null 2>/dev/null | grep -A3 "Certificate chain" | grep "s:" | wc -l | xargs echo "  Certificates in chain:"

echo ""
echo "================================================"
echo "✅ Fix Complete!"
echo "================================================"
echo ""
echo "Both domains now have proper certificate chains."
echo ""
echo "Please test in browser:"
echo "  - https://showcase.vibytes.tech"
echo "  - https://auth.vibytes.tech"
echo ""
echo "Should show 🔒 secure lock icon"
echo ""

ENDSSH
fi

echo ""
echo "================================================"
echo "✅ SSL Chains Fixed Successfully!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Hard refresh browser (Ctrl+Shift+R)"
echo "  2. Or open incognito/private window"
echo "  3. Visit both domains"
echo "  4. Verify 🔒 secure lock icon"
echo ""
echo "Test URLs:"
echo "  https://showcase.vibytes.tech"
echo "  https://auth.vibytes.tech"
echo ""

