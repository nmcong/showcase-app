#!/bin/bash

# Simple VPS setup for showcase-only (no database, no Keycloak)

set -e

echo "================================================"
echo "Simple VPS Setup for Showcase"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "VPS: $VPS_USER@$VPS_HOST"
echo ""
echo "This will install:"
echo "  - Node.js 20.x"
echo "  - Nginx"
echo "  - PM2"
echo "  - Certbot (for SSL)"
echo ""

# Create setup script
cat > /tmp/vps-setup.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Installing System Dependencies"
echo "================================================"

# Update system
sudo apt-get update
sudo apt-get upgrade -y

echo "✓ System updated"

echo ""
echo "================================================"
echo "Installing Node.js 20.x"
echo "================================================"

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version

echo "✓ Node.js installed"

echo ""
echo "================================================"
echo "Installing PM2"
echo "================================================"

sudo npm install -g pm2

# Verify installation
pm2 --version

echo "✓ PM2 installed"

echo ""
echo "================================================"
echo "Installing Nginx"
echo "================================================"

sudo apt-get install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "✓ Nginx installed"

echo ""
echo "================================================"
echo "Installing Certbot"
echo "================================================"

sudo apt-get install -y certbot python3-certbot-nginx

echo "✓ Certbot installed"

echo ""
echo "================================================"
echo "Installing Git"
echo "================================================"

sudo apt-get install -y git

echo "✓ Git installed"

echo ""
echo "================================================"
echo "Creating Application Directory"
echo "================================================"

sudo mkdir -p $APP_INSTALL_PATH
sudo chown -R $USER:$USER $APP_INSTALL_PATH

echo "✓ Application directory created: $APP_INSTALL_PATH"

echo ""
echo "================================================"
echo "Configuring Firewall"
echo "================================================"

# Configure UFW firewall
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw --force enable

echo "✓ Firewall configured"

echo ""
echo "================================================"
echo "System Information"
echo "================================================"

echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "PM2: $(pm2 --version)"
echo "Nginx: $(nginx -v 2>&1)"
echo "Git: $(git --version)"

echo ""
echo "================================================"
echo "VPS Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Run deploy script: ./scripts/deploy-showcase-simple.sh"
echo "  2. Setup Nginx: ./scripts/setup-nginx-simple.sh"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing setup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/vps-setup.sh" < /tmp/vps-setup.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         bash /tmp/vps-setup.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/vps-setup.sh" < /tmp/vps-setup.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         bash /tmp/vps-setup.sh"
fi

echo ""
echo "✓ VPS setup completed successfully!"
echo ""

