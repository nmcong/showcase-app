#!/bin/bash

# ================================================
# Full Deployment Script
# ================================================
# Chạy tất cả các bước deploy tự động
# ================================================

set -e

echo "================================================"
echo "Full Deployment Script"
echo "================================================"
echo "This script will:"
echo "  1. Setup VPS (install dependencies)"
echo "  2. Setup database"
echo "  3. Install Keycloak"
echo "  4. Deploy application"
echo "  5. Configure Nginx"
echo ""

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
    echo "✓ Loaded .env.deploy"
else
    echo "✗ Error: .env.deploy not found!"
    echo ""
    echo "Please create .env.deploy from env.deploy.example:"
    echo "  cp env.deploy.example .env.deploy"
    echo "  nano .env.deploy"
    exit 1
fi

echo ""
echo "Deployment Configuration Summary:"
echo "--------------------------------"
echo "VPS: $VPS_USER@$VPS_HOST:$VPS_PORT"
echo "App Domain: $APP_DOMAIN"
echo "Keycloak Domain: $KEYCLOAK_DOMAIN"
echo "Database: $DB_NAME"
echo "Keycloak Version: $KEYCLOAK_VERSION"
echo ""

read -p "Continue with full deployment? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Track start time
START_TIME=$(date +%s)

# Step 1: Setup VPS
echo ""
echo "================================================"
echo "Step 1/5: Setting Up VPS"
echo "================================================"
./scripts/setup-vps.sh
echo "✓ Step 1 completed"

# Step 2: Setup Database
echo ""
echo "================================================"
echo "Step 2/5: Setting Up Database"
echo "================================================"
./scripts/setup-database.sh
echo "✓ Step 2 completed"

# Step 3: Install Keycloak
echo ""
echo "================================================"
echo "Step 3/5: Installing Keycloak"
echo "================================================"
./scripts/install-keycloak.sh
echo "✓ Step 3 completed"

# Step 4: Deploy Application
echo ""
echo "================================================"
echo "Step 4/5: Deploying Application"
echo "================================================"
./scripts/deploy-app.sh
echo "✓ Step 4 completed"

# Step 5: Configure Nginx
echo ""
echo "================================================"
echo "Step 5/5: Configuring Nginx"
echo "================================================"
./scripts/setup-nginx.sh
echo "✓ Step 5 completed"

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "================================================"
echo "🎉 Full Deployment Completed Successfully! 🎉"
echo "================================================"
echo ""
echo "Deployment time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Your showcase is now live at:"
echo "  🌐 App: https://$APP_DOMAIN"
echo "  🔐 Keycloak: https://$KEYCLOAK_DOMAIN"
echo ""
echo "Next steps:"
echo "  1. Configure Keycloak realm and client:"
echo "     - Visit https://$KEYCLOAK_DOMAIN"
echo "     - Login with admin credentials"
echo "     - Create realm: showcase-realm"
echo "     - Create client: $KEYCLOAK_CLIENT_ID"
echo "     - Copy client secret to .env.deploy"
echo "     - Redeploy app: ./scripts/deploy-app.sh"
echo ""
echo "  2. Test your application:"
echo "     - Visit https://$APP_DOMAIN"
echo "     - Try login functionality"
echo "     - Check 3D model viewer"
echo ""
echo "  3. Monitor services:"
echo "     - App logs: pm2 logs showcase-app"
echo "     - Keycloak logs: sudo journalctl -u keycloak -f"
echo "     - Nginx logs: sudo tail -f /var/log/nginx/*.log"
echo ""
echo "Useful commands:"
echo "  ./scripts/deploy-app.sh     # Redeploy app"
echo "  ./scripts/backup.sh          # Create backup"
echo "  ./scripts/update-app.sh      # Update app"
echo ""
echo "================================================"

