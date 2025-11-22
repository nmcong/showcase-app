#!/bin/bash

# ================================================
# Keycloak Installation Script (Standalone - No Docker)
# ================================================
# Cài đặt Keycloak 26.4.5 trực tiếp trên VPS
# ================================================

set -e

echo "================================================"
echo "Keycloak Installation Script"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "Keycloak Configuration:"
echo "----------------------"
echo "Version: $KEYCLOAK_VERSION"
echo "Install Path: $KEYCLOAK_INSTALL_PATH"
echo "Domain: $KEYCLOAK_DOMAIN"
echo "Admin User: $KEYCLOAK_ADMIN"
echo ""

# Create installation script
cat > /tmp/keycloak-install-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Installing Keycloak $KEYCLOAK_VERSION"
echo "================================================"

cd /tmp

# Download Keycloak
echo "Downloading Keycloak $KEYCLOAK_VERSION..."
wget -q --show-progress \
    https://github.com/keycloak/keycloak/releases/download/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz

# Remove existing Keycloak installation if exists
if [ -d "$KEYCLOAK_INSTALL_PATH" ]; then
    echo "Removing existing Keycloak installation..."
    sudo systemctl stop keycloak || true
    sudo rm -rf $KEYCLOAK_INSTALL_PATH
fi

# Extract
echo "Extracting..."
sudo tar -xzf keycloak-$KEYCLOAK_VERSION.tar.gz -C /opt/

# Move to final location
if [ -d "/opt/keycloak-$KEYCLOAK_VERSION" ]; then
    sudo mv /opt/keycloak-$KEYCLOAK_VERSION $KEYCLOAK_INSTALL_PATH
else
    echo "✗ Error: Extracted Keycloak directory not found"
    echo "Contents of /opt/:"
    ls -la /opt/ | grep keycloak
    exit 1
fi

# Cleanup
rm keycloak-$KEYCLOAK_VERSION.tar.gz

echo "✓ Keycloak extracted to $KEYCLOAK_INSTALL_PATH"
echo "Directory structure:"
ls -la $KEYCLOAK_INSTALL_PATH/ | head -n 20

echo ""
echo "================================================"
echo "Configuring Keycloak"
echo "================================================"

# Create keycloak user
sudo useradd -r -s /bin/false keycloak || true

# Check directory structure and create conf directory if needed
if [ ! -d "$KEYCLOAK_INSTALL_PATH/conf" ]; then
    echo "Creating conf directory..."
    sudo mkdir -p $KEYCLOAK_INSTALL_PATH/conf
fi

sudo chown -R keycloak:keycloak $KEYCLOAK_INSTALL_PATH

# Create configuration file
sudo tee $KEYCLOAK_INSTALL_PATH/conf/keycloak.conf > /dev/null << KCCONF
# Database
db=postgres
db-username=$KEYCLOAK_DB_USER
db-password=$KEYCLOAK_DB_PASSWORD
db-url=jdbc:postgresql://localhost:5432/$KEYCLOAK_DB_NAME

# HTTP
http-enabled=true
http-port=8080
http-host=0.0.0.0
hostname=$KEYCLOAK_DOMAIN
hostname-strict=false
hostname-strict-https=false

# Proxy
proxy-headers=xforwarded
proxy=edge

# Observability
health-enabled=true
metrics-enabled=true
log-level=info

# Performance
cache=ispn
cache-stack=tcp

# Admin
https-port=8443
KCCONF

echo "✓ Keycloak configured"

echo ""
echo "================================================"
echo "Verifying Database Credentials"
echo "================================================"

# Fix database user password to ensure it matches config
sudo -u postgres psql << 'DBFIX'
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$KEYCLOAK_DB_USER') THEN
    ALTER USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE $KEYCLOAK_DB_NAME TO $KEYCLOAK_DB_USER;
\c $KEYCLOAK_DB_NAME
GRANT ALL ON SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $KEYCLOAK_DB_USER;
DBFIX

# Test database connection
echo "Testing database connection..."
if PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Database connection verified"
else
    echo "✗ Warning: Database connection test failed, but continuing..."
fi

echo ""
echo "================================================"
echo "Building Keycloak"
echo "================================================"

# Build Keycloak
cd $KEYCLOAK_INSTALL_PATH
export KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN
export KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD

echo "Building optimized Keycloak (this may take a few minutes)..."
sudo -u keycloak \
    KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN \
    KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
    JAVA_OPTS="-Xms$KEYCLOAK_JVM_XMS -Xmx$KEYCLOAK_JVM_XMX" \
    bin/kc.sh build

echo "✓ Keycloak built successfully"

echo ""
echo "================================================"
echo "Creating Systemd Service"
echo "================================================"

# Create systemd service
sudo tee /etc/systemd/system/keycloak.service > /dev/null << SYSTEMDCONF
[Unit]
Description=Keycloak Identity and Access Management
Documentation=https://www.keycloak.org/documentation
After=network.target postgresql.service

[Service]
Type=exec
User=keycloak
Group=keycloak
WorkingDirectory=$KEYCLOAK_INSTALL_PATH

# Environment
Environment="KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN"
Environment="KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD"
Environment="JAVA_OPTS=-Xms$KEYCLOAK_JVM_XMS -Xmx$KEYCLOAK_JVM_XMX -XX:MetaspaceSize=256M -XX:MaxMetaspaceSize=512m -XX:+UseG1GC"

ExecStart=$KEYCLOAK_INSTALL_PATH/bin/kc.sh start --optimized

StandardOutput=journal
StandardError=journal
SyslogIdentifier=keycloak

# Restart policy
Restart=on-failure
RestartSec=10s

# Resource limits
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
SYSTEMDCONF

echo "✓ Systemd service created"

echo ""
echo "================================================"
echo "Starting Keycloak"
echo "================================================"

# Reload systemd
sudo systemctl daemon-reload

# Enable and start Keycloak
sudo systemctl enable keycloak
sudo systemctl start keycloak

echo "Waiting for Keycloak to start (this may take 60-90 seconds)..."
sleep 60

# Check status
sudo systemctl status keycloak --no-pager || true

echo ""
echo "Testing Keycloak health..."
for i in {1..10}; do
    if curl -sf http://localhost:8080/health/ready > /dev/null 2>&1; then
        echo "✓ Keycloak is ready!"
        break
    else
        echo "  Waiting... ($i/10)"
        sleep 10
    fi
done

echo ""
echo "================================================"
echo "Keycloak Installation Complete!"
echo "================================================"
echo ""
echo "Keycloak Information:"
echo "  Version: $KEYCLOAK_VERSION"
echo "  Install Path: $KEYCLOAK_INSTALL_PATH"
echo "  Service: keycloak.service"
echo "  Port: 8080"
echo "  Admin User: $KEYCLOAK_ADMIN"
echo ""
echo "Useful commands:"
echo "  sudo systemctl status keycloak"
echo "  sudo systemctl restart keycloak"
echo "  sudo systemctl stop keycloak"
echo "  sudo journalctl -u keycloak -f"
echo ""
echo "Access Keycloak at: http://$VPS_HOST:8080"
echo "(Configure Nginx reverse proxy for HTTPS)"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing Keycloak installation on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    # Send environment variables and script
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/keycloak-install-script.sh" < /tmp/keycloak-install-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_VERSION='$KEYCLOAK_VERSION' && \
         export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_JVM_XMS='$KEYCLOAK_JVM_XMS' && \
         export KEYCLOAK_JVM_XMX='$KEYCLOAK_JVM_XMX' && \
         bash /tmp/keycloak-install-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/keycloak-install-script.sh" < /tmp/keycloak-install-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_VERSION='$KEYCLOAK_VERSION' && \
         export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_JVM_XMS='$KEYCLOAK_JVM_XMS' && \
         export KEYCLOAK_JVM_XMX='$KEYCLOAK_JVM_XMX' && \
         bash /tmp/keycloak-install-script.sh"
fi

echo ""
echo "✓ Keycloak installation completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Configure Nginx reverse proxy: ./scripts/setup-nginx.sh"
echo "  2. Deploy application: ./scripts/deploy-app.sh"
echo ""

