#!/bin/bash

# ================================================
# Generate Self-Signed Certificates
# ================================================
# Dùng cho testing/development
# Production nên dùng certificates từ SSL provider chính thức
# ================================================

set -e

echo "================================================"
echo "Generate Self-Signed Certificates"
echo "================================================"
echo ""
echo "⚠️  WARNING: Self-signed certificates chỉ nên dùng cho testing!"
echo "   Production nên dùng certificates từ Let's Encrypt hoặc SSL provider."
echo ""

# Generate certificate for auth.vibytes.tech
echo "Generating certificate for auth.vibytes.tech..."
openssl req -new -x509 \
    -key ca/auth/private_key_auth-vibytes-tech.txt \
    -out ca/auth/certificate_auth-vibytes-tech.txt \
    -days 365 \
    -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=Vibytes/CN=auth.vibytes.tech" \
    -addext "subjectAltName=DNS:auth.vibytes.tech"

echo "✓ Certificate created: ca/auth/certificate_auth-vibytes-tech.txt"

# Verify
echo ""
echo "Verifying auth certificate..."
openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -text -noout | grep -E "(Subject:|DNS:)"
openssl verify -CAfile ca/auth/certificate_auth-vibytes-tech.txt ca/auth/certificate_auth-vibytes-tech.txt || true

echo ""
echo "Checking if key and cert match..."
AUTH_KEY_MD5=$(openssl rsa -in ca/auth/private_key_auth-vibytes-tech.txt -modulus -noout | openssl md5)
AUTH_CERT_MD5=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -modulus -noout | openssl md5)

if [ "$AUTH_KEY_MD5" = "$AUTH_CERT_MD5" ]; then
    echo "✓ Auth: Private key and certificate MATCH!"
else
    echo "✗ Auth: Private key and certificate DO NOT match!"
    exit 1
fi

# Generate certificate for showcase.vibytes.tech
echo ""
echo "Generating certificate for showcase.vibytes.tech..."
openssl req -new -x509 \
    -key ca/showcase/private_key_showcase-vibytes-tech.txt \
    -out ca/showcase/certificate_showcase-vibytes-tech.txt \
    -days 365 \
    -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=Vibytes/CN=showcase.vibytes.tech" \
    -addext "subjectAltName=DNS:showcase.vibytes.tech"

echo "✓ Certificate created: ca/showcase/certificate_showcase-vibytes-tech.txt"

# Verify
echo ""
echo "Verifying showcase certificate..."
openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -text -noout | grep -E "(Subject:|DNS:)"
openssl verify -CAfile ca/showcase/certificate_showcase-vibytes-tech.txt ca/showcase/certificate_showcase-vibytes-tech.txt || true

echo ""
echo "Checking if key and cert match..."
SHOWCASE_KEY_MD5=$(openssl rsa -in ca/showcase/private_key_showcase-vibytes-tech.txt -modulus -noout | openssl md5)
SHOWCASE_CERT_MD5=$(openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -modulus -noout | openssl md5)

if [ "$SHOWCASE_KEY_MD5" = "$SHOWCASE_CERT_MD5" ]; then
    echo "✓ Showcase: Private key and certificate MATCH!"
else
    echo "✗ Showcase: Private key and certificate DO NOT match!"
    exit 1
fi

echo ""
echo "================================================"
echo "Certificates Generated Successfully!"
echo "================================================"
echo ""
echo "Files created:"
echo "  - ca/auth/certificate_auth-vibytes-tech.txt"
echo "  - ca/showcase/certificate_showcase-vibytes-tech.txt"
echo ""
echo "Valid for: 365 days"
echo ""
echo "⚠️  Note: Browsers will show security warnings for self-signed certificates."
echo "   This is normal. You can:"
echo "   - Click 'Advanced' -> 'Proceed to site' in browser"
echo "   - Or use curl with -k flag: curl -k https://auth.vibytes.tech"
echo ""
echo "Next step: Run SSL setup"
echo "  ./scripts/setup-ssl.sh"
echo ""

