#!/bin/bash

# Auto-deploy without confirmation prompt (Database-free version)

set -e

echo "================================================"
echo "Automatic Application Deployment"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "Deployment Configuration:"
echo "------------------------"
echo "VPS: $VPS_USER@$VPS_HOST"
echo "Install Path: $APP_INSTALL_PATH"
echo "Domain: $APP_DOMAIN"
echo "Git Repo: $GIT_REPO_URL"
echo "Branch: $GIT_BRANCH"
echo ""
echo "Starting deployment..."

# Create deployment script
cat > /tmp/app-deploy-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

echo "================================================"
echo "Deploying Application"
echo "================================================"

# Clone or update repository
if [ -d "$APP_INSTALL_PATH/.git" ]; then
    echo "Updating existing repository..."
    cd $APP_INSTALL_PATH
    # Clean any local changes
    git clean -fd
    git fetch origin
    git reset --hard origin/$GIT_BRANCH
else
    echo "Cloning repository..."
    sudo rm -rf $APP_INSTALL_PATH
    sudo git clone -b $GIT_BRANCH $GIT_REPO_URL $APP_INSTALL_PATH
    cd $APP_INSTALL_PATH
fi

echo "✓ Code updated"

echo ""
echo "================================================"
echo "Creating Environment Files"
echo "================================================"

# Create .env.local for Next.js
sudo tee $APP_INSTALL_PATH/.env.local > /dev/null << ENVFILE
# Keycloak
NEXT_PUBLIC_KEYCLOAK_URL="https://$KEYCLOAK_DOMAIN"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="$KEYCLOAK_CLIENT_ID"
KEYCLOAK_CLIENT_SECRET="$KEYCLOAK_CLIENT_SECRET"

# Application
NEXT_PUBLIC_APP_URL="https://$APP_DOMAIN"
NODE_ENV="$NODE_ENV"
ENVFILE

echo "✓ Environment files created"

echo ""
echo "================================================"
echo "Installing Dependencies"
echo "================================================"

cd $APP_INSTALL_PATH
sudo npm install --production=false

echo "✓ Dependencies installed"

echo ""
echo "================================================"
echo "Building Application"
echo "================================================"

sudo npm run build

echo "✓ Application built"

echo ""
echo "================================================"
echo "Configuring PM2"
echo "================================================"

# Create PM2 ecosystem file
sudo tee $APP_INSTALL_PATH/ecosystem.config.js > /dev/null << PM2CONF
module.exports = {
  apps: [{
    name: 'showcase-app',
    script: 'npm',
    args: 'start',
    cwd: '$APP_INSTALL_PATH',
    instances: $PM2_INSTANCES,
    exec_mode: 'cluster',
    max_memory_restart: '$PM2_MAX_MEMORY',
    env: {
      NODE_ENV: '$NODE_ENV',
      PORT: $APP_PORT
    },
    error_file: '/var/log/pm2/showcase-app-error.log',
    out_file: '/var/log/pm2/showcase-app-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
PM2CONF

# Create log directory
sudo mkdir -p /var/log/pm2

# Stop existing app if running
pm2 delete showcase-app || true

# Start app with PM2
cd $APP_INSTALL_PATH
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 startup script
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u $USER --hp /home/$USER || true

echo "✓ PM2 configured and app started"

echo ""
echo "================================================"
echo "Application Status"
echo "================================================"

pm2 list
pm2 info showcase-app

echo ""
echo "================================================"
echo "Deployment Complete!"
echo "================================================"
echo ""
echo "Application Information:"
echo "  Path: $APP_INSTALL_PATH"
echo "  Port: $APP_PORT"
echo "  Domain: $APP_DOMAIN"
echo "  PM2 App: showcase-app"
echo ""
echo "Useful commands:"
echo "  pm2 list"
echo "  pm2 logs showcase-app"
echo "  pm2 restart showcase-app"
echo "  pm2 stop showcase-app"
echo "  pm2 monit"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing deployment on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/app-deploy-script.sh" < /tmp/app-deploy-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export LC_ALL=C.UTF-8 && \
         export LANG=C.UTF-8 && \
         export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export GIT_REPO_URL='$GIT_REPO_URL' && \
         export GIT_BRANCH='$GIT_BRANCH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_CLIENT_ID='$KEYCLOAK_CLIENT_ID' && \
         export KEYCLOAK_CLIENT_SECRET='$KEYCLOAK_CLIENT_SECRET' && \
         export NODE_ENV='$NODE_ENV' && \
         export PM2_INSTANCES='$PM2_INSTANCES' && \
         export PM2_MAX_MEMORY='$PM2_MAX_MEMORY' && \
         bash /tmp/app-deploy-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/app-deploy-script.sh" < /tmp/app-deploy-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export LC_ALL=C.UTF-8 && \
         export LANG=C.UTF-8 && \
         export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         export APP_DOMAIN='$APP_DOMAIN' && \
         export APP_PORT='$APP_PORT' && \
         export GIT_REPO_URL='$GIT_REPO_URL' && \
         export GIT_BRANCH='$GIT_BRANCH' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_CLIENT_ID='$KEYCLOAK_CLIENT_ID' && \
         export KEYCLOAK_CLIENT_SECRET='$KEYCLOAK_CLIENT_SECRET' && \
         export NODE_ENV='$NODE_ENV' && \
         export PM2_INSTANCES='$PM2_INSTANCES' && \
         export PM2_MAX_MEMORY='$PM2_MAX_MEMORY' && \
         bash /tmp/app-deploy-script.sh"
fi

echo ""
echo "✓ Application deployment completed successfully!"
echo ""
