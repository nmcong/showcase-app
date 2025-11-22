#!/bin/bash

# ================================================
# Full Deployment Script - Database-Free Version
# ================================================
# Script này deploy application mà không cần database
# ================================================

set -e

echo "================================================"
echo "Full Deployment - Database-Free Version"
echo "================================================"
echo ""
echo "This script will:"
echo "  1. Setup VPS with all dependencies"
echo "  2. Install and configure Keycloak"
echo "  3. Deploy Next.js application"
echo "  4. Setup Nginx reverse proxy"
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
echo "Step 1/4: Setting up VPS"
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
echo "Step 2/4: Installing Keycloak"
echo "================================================"

if [ -f "scripts/install-keycloak.sh" ]; then
    echo "Running Keycloak installation..."
    ./scripts/install-keycloak.sh
    echo "✓ Keycloak installation completed"
else
    echo "⚠ Warning: install-keycloak.sh not found, skipping..."
fi

echo ""
echo "================================================"
echo "Step 3/4: Deploying Application"
echo "================================================"

if [ -f "scripts/deploy-app-auto.sh" ]; then
    echo "Running application deployment..."
    ./scripts/deploy-app-auto.sh
    echo "✓ Application deployment completed"
else
    echo "✗ Error: deploy-app-auto.sh not found!"
    exit 1
fi

echo ""
echo "================================================"
echo "Step 4/4: Setting up Nginx"
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
echo "For troubleshooting, see: docs/13-TROUBLESHOOTING.md"
echo ""
