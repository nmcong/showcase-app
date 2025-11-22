#!/bin/bash

# ================================================
# Generate CSR from existing private keys
# ================================================

set -e

echo "================================================"
echo "Generate CSR for SSL Certificate Request"
echo "================================================"
echo ""

# Generate CSR for auth.vibytes.tech
echo "Generating CSR for auth.vibytes.tech..."
openssl req -new \
    -key ca/auth/private_key_auth-vibytes-tech.txt \
    -out ca/auth/auth-vibytes-tech.csr \
    -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=Vibytes/CN=auth.vibytes.tech"

echo "✓ CSR created: ca/auth/auth-vibytes-tech.csr"
echo ""
echo "CSR Content:"
cat ca/auth/auth-vibytes-tech.csr
echo ""

# Generate CSR for showcase.vibytes.tech
echo "Generating CSR for showcase.vibytes.tech..."
openssl req -new \
    -key ca/showcase/private_key_showcase-vibytes-tech.txt \
    -out ca/showcase/showcase-vibytes-tech.csr \
    -subj "/C=VN/ST=HoChiMinh/L=HoChiMinh/O=Vibytes/CN=showcase.vibytes.tech"

echo "✓ CSR created: ca/showcase/showcase-vibytes-tech.csr"
echo ""
echo "CSR Content:"
cat ca/showcase/showcase-vibytes-tech.csr
echo ""

echo "================================================"
echo "Next Steps:"
echo "================================================"
echo ""
echo "1. Submit these CSRs to your SSL provider (Sectigo/Let's Encrypt/etc.)"
echo "2. Download the domain certificates they provide"
echo "3. Save domain certificates as:"
echo "   - ca/auth/certificate_auth-vibytes-tech.txt"
echo "   - ca/showcase/certificate_showcase-vibytes-tech.txt"
echo "4. Run ./scripts/setup-ssl.sh again"
echo ""

