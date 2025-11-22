#!/bin/bash

# Full deployment script for showcase-only (all-in-one)

set -e

echo "================================================"
echo "Full Showcase Deployment"
echo "================================================"
echo ""
echo "This will:"
echo "  1. Setup VPS (Node.js, Nginx, PM2)"
echo "  2. Deploy application"
echo "  3. Configure Nginx with SSL"
echo ""
echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
sleep 5

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "Step 1/3: Setting up VPS..."
echo "================================================"
bash "$SCRIPT_DIR/setup-vps-simple.sh"

echo ""
echo "Step 2/3: Deploying application..."
echo "================================================"
bash "$SCRIPT_DIR/deploy-showcase-simple.sh"

echo ""
echo "Step 3/3: Configuring Nginx with SSL..."
echo "================================================"
bash "$SCRIPT_DIR/setup-nginx-simple.sh"

echo ""
echo "================================================"
echo "Full Deployment Complete!"
echo "================================================"
echo ""
echo "Your application should now be live at:"
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
    echo "  https://$APP_DOMAIN"
fi
echo ""
echo "Useful commands:"
echo "  pm2 list                    - List running apps"
echo "  pm2 logs showcase-app       - View app logs"
echo "  pm2 restart showcase-app    - Restart app"
echo "  sudo systemctl status nginx - Check Nginx status"
echo "  sudo certbot renew --dry-run - Test SSL renewal"
echo ""
echo "================================================"

