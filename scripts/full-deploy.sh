#!/bin/bash

# ================================================
# Full Deployment Script - All Fixes Integrated
# ================================================
# Script này đã integrate TẤT CẢ các fixes
# Chạy script này để deploy hoàn toàn mà không cần fix scripts
# ================================================

set -e

echo "================================================"
echo "Full Deployment - Fixed Version"
echo "================================================"
echo ""
echo "This script includes all fixes and will:"
echo "  1. Setup VPS with all dependencies"
echo "  2. Setup databases with password fixes"
echo "  3. Install and configure Keycloak"
echo "  4. Deploy Next.js application"
echo "  5. Setup Nginx reverse proxy"
echo ""

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
    echo "✓ Loaded .env.deploy"
else
    echo "✗ Error: .env.deploy not found!"
    echo "  Please copy .env.deploy.example to .env.deploy and configure it."
    exit 1
fi

echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "VPS Host: $VPS_HOST"
echo "VPS User: $VPS_USER"
echo "App Domain: $APP_DOMAIN"
echo "Keycloak Domain: $KEYCLOAK_DOMAIN"
echo ""

read -p "Continue with full deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "================================================"
echo "Step 1/5: Setting up VPS"
echo "================================================"

if [ -f "scripts/setup-vps.sh" ]; then
    echo "Running VPS setup..."
    ./scripts/setup-vps.sh
    echo "✓ VPS setup completed"
else
    echo "⚠ Warning: setup-vps.sh not found, skipping..."
fi

echo ""
echo "================================================"
echo "Step 2/5: Setting up Databases (with fixes)"
echo "================================================"

# Run database setup (already includes fixes)
if [ -f "scripts/setup-database.sh" ]; then
    echo "Running database setup..."
    ./scripts/setup-database.sh
    echo "✓ Database setup completed"
else
    echo "✗ Error: setup-database.sh not found!"
    exit 1
fi

echo ""
echo "================================================"
echo "Step 3/5: Installing Keycloak"
echo "================================================"

if [ -f "scripts/install-keycloak.sh" ]; then
    echo "Running Keycloak installation (includes database fixes)..."
    ./scripts/install-keycloak.sh
    echo "✓ Keycloak installation completed"
else
    echo "⚠ Warning: install-keycloak.sh not found, skipping..."
fi

echo ""
echo "================================================"
echo "Step 4/5: Deploying Application"
echo "================================================"

if [ -f "scripts/deploy-app-auto.sh" ]; then
    echo "Running application deployment (includes database fixes)..."
    ./scripts/deploy-app-auto.sh
    echo "✓ Application deployment completed"
else
    echo "✗ Error: deploy-app-auto.sh not found!"
    exit 1
fi

echo ""
echo "================================================"
echo "Step 5/5: Setting up Nginx"
echo "================================================"

if [ -f "scripts/setup-nginx.sh" ]; then
    echo "Running Nginx setup..."
    ./scripts/setup-nginx.sh
    echo "✓ Nginx setup completed"
else
    echo "⚠ Warning: setup-nginx.sh not found, skipping..."
fi

echo ""
echo "================================================"
echo "Deployment Summary"
echo "================================================"

# Run status check
if [ -f "scripts/check-status.sh" ]; then
    echo ""
    echo "Checking services status..."
    ./scripts/check-status.sh | tail -50
fi

echo ""
echo "================================================"
echo "✅ Full Deployment Completed!"
echo "================================================"
echo ""
echo "Your applications are now running:"
echo "  App: http://$APP_DOMAIN (or https:// if SSL configured)"
echo "  Keycloak: http://$KEYCLOAK_DOMAIN (or https:// if SSL configured)"
echo ""
echo "Next steps:"
echo "  1. Setup SSL certificates:"
echo "     - For Showcase: ./scripts/setup-ssl-showcase-only.sh"
echo "  2. Configure Keycloak:"
echo "     - Access: http://$KEYCLOAK_DOMAIN/admin/"
echo "     - Login with credentials from .env.deploy"
echo "     - Create realm: showcase-realm"
echo "     - Create client: showcase-client"
echo "  3. Monitor services:"
echo "     - pm2 logs showcase-app"
echo "     - sudo journalctl -u keycloak -f"
echo ""
echo "For troubleshooting, see: docs/12-TROUBLESHOOTING.md"
echo ""

