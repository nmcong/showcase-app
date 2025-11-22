#!/bin/bash

# ================================================
# VPS Initial Setup Script (Without Docker)
# ================================================
# Script này sẽ cài đặt tất cả các dependencies cần thiết
# trên VPS mà KHÔNG sử dụng Docker
# ================================================

set -e  # Exit on error

echo "================================================"
echo "VPS Setup Script - No Docker"
echo "================================================"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ Loaded .env"
else
    echo "✗ Error: .env not found!"
    echo "  Please copy .env.example to .env and configure it."
    exit 1
fi

echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "VPS Host: $VPS_HOST"
echo "VPS User: $VPS_USER"
echo "App Domain: $APP_DOMAIN"
echo "Keycloak Domain: $KEYCLOAK_DOMAIN"
echo "App Install Path: $APP_INSTALL_PATH"
echo "Keycloak Install Path: $KEYCLOAK_INSTALL_PATH"
echo ""

read -p "Continue with this configuration? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "================================================"
echo "Step 1: Update System & Install Dependencies"
echo "================================================"

# Create setup script to run on VPS
cat > /tmp/vps-setup-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt update
sudo apt upgrade -y

echo "Installing essential tools..."
sudo apt install -y \
    curl \
    wget \
    git \
    build-essential \
    ufw \
    nano \
    htop \
    net-tools \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

echo "✓ System updated and tools installed"

echo ""
echo "================================================"
echo "Installing Node.js 20.x..."
echo "================================================"

curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

echo ""
echo "================================================"
echo "Installing PostgreSQL..."
echo "================================================"

sudo apt install -y postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "PostgreSQL version: $(psql --version)"
echo "✓ PostgreSQL installed and started"

echo ""
echo "================================================"
echo "Installing Nginx..."
echo "================================================"

sudo apt install -y nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Nginx version: $(nginx -v)"
echo "✓ Nginx installed and started"

echo ""
echo "================================================"
echo "Installing Java 21 (for Keycloak)..."
echo "================================================"

# Install Java 21
sudo apt install -y openjdk-21-jdk

echo "Java version: $(java -version 2>&1 | head -n 1)"
echo "✓ Java installed"

echo ""
echo "================================================"
echo "Installing PM2..."
echo "================================================"

sudo npm install -g pm2

echo "PM2 version: $(pm2 --version)"
echo "✓ PM2 installed"

echo ""
echo "================================================"
echo "Installing Certbot (for SSL)..."
echo "================================================"

sudo apt install -y certbot python3-certbot-nginx

echo "Certbot version: $(certbot --version)"
echo "✓ Certbot installed"

echo ""
echo "================================================"
echo "Configuring Firewall..."
echo "================================================"

# Configure UFW
sudo ufw --force enable
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

echo "✓ Firewall configured"

echo ""
echo "================================================"
echo "Creating Directory Structure..."
echo "================================================"

# Create directories
sudo mkdir -p /opt/keycloak
sudo mkdir -p /var/www/showcase-app
sudo mkdir -p /var/backups/showcase

echo "✓ Directories created"

echo ""
echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo "Installed components:"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - PostgreSQL: $(psql --version | head -n 1)"
echo "  - Nginx: $(nginx -v 2>&1)"
echo "  - Java: $(java -version 2>&1 | head -n 1)"
echo "  - PM2: $(pm2 --version)"
echo "  - Certbot: $(certbot --version 2>&1 | head -n 1)"
echo ""
echo "Next steps:"
echo "  1. Run database setup script"
echo "  2. Install Keycloak"
echo "  3. Deploy application"
echo "================================================"

REMOTESCRIPT

# Copy and execute script on VPS
echo "Connecting to VPS and running setup..."

if [ -n "$VPS_PASSWORD" ]; then
    # Using sshpass for password authentication
    if ! command -v sshpass &> /dev/null; then
        echo "Error: sshpass is not installed!"
        echo "On macOS, install it with: brew install hudochenkov/sshpass/sshpass"
        echo "On Linux, install it with: sudo apt-get install -y sshpass"
        exit 1
    fi
    
    sshpass -p "$VPS_PASSWORD" scp -o StrictHostKeyChecking=no -P "$VPS_PORT" \
        /tmp/vps-setup-script.sh "$VPS_USER@$VPS_HOST:/tmp/"
    
    sshpass -p "$VPS_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash /tmp/vps-setup-script.sh"
else
    # Using SSH key
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        /tmp/vps-setup-script.sh "$VPS_USER@$VPS_HOST:/tmp/"
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash /tmp/vps-setup-script.sh"
fi

echo ""
echo "================================================"
echo "VPS Setup Completed Successfully!"
echo "================================================"
echo ""
echo "Next step: Run database setup"
echo "  ./scripts/setup-database.sh"
echo ""

