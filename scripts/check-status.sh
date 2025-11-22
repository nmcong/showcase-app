#!/bin/bash

# ================================================
# Check Services Status Script
# ================================================
# Kiểm tra status của tất cả services trên VPS
# ================================================

set -e

echo "================================================"
echo "Services Status Check"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

# Create check script
cat > /tmp/check-status-script.sh << 'REMOTESCRIPT'
#!/bin/bash

echo ""
echo "================================================"
echo "1. Keycloak Service Status"
echo "================================================"
sudo systemctl status keycloak --no-pager || echo "✗ Keycloak service not running"

echo ""
echo "Checking if Keycloak is listening on port 8080..."
sudo netstat -tlnp | grep :8080 || echo "✗ Nothing listening on port 8080"

echo ""
echo "Testing Keycloak health endpoint..."
curl -s http://localhost:8080/health/ready || echo "✗ Keycloak health check failed"

echo ""
echo "================================================"
echo "2. Next.js App Status (PM2)"
echo "================================================"
pm2 list || echo "✗ PM2 not found or no apps running"

echo ""
echo "Checking if app is listening on port $APP_PORT..."
sudo netstat -tlnp | grep :$APP_PORT || echo "✗ Nothing listening on port $APP_PORT"

echo ""
echo "Testing app endpoint..."
curl -s http://localhost:$APP_PORT || echo "✗ App health check failed"

echo ""
echo "================================================"
echo "3. Nginx Status"
echo "================================================"
sudo systemctl status nginx --no-pager || echo "✗ Nginx service not running"

echo ""
echo "Nginx configuration test:"
sudo nginx -t

echo ""
echo "================================================"
echo "4. PostgreSQL Status"
echo "================================================"
sudo systemctl status postgresql --no-pager || echo "✗ PostgreSQL service not running"

echo ""
echo "================================================"
echo "5. Recent Logs"
echo "================================================"

echo ""
echo "Last 10 lines of Keycloak logs:"
sudo journalctl -u keycloak -n 10 --no-pager || echo "No Keycloak logs"

echo ""
echo "Last 10 lines of PM2 logs:"
pm2 logs showcase-app --lines 10 --nostream || echo "No PM2 logs"

echo ""
echo "Last 10 lines of Nginx error log:"
sudo tail -n 10 /var/log/nginx/error.log || echo "No Nginx error logs"

echo ""
echo "================================================"
echo "Status Check Complete"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Connecting to VPS and checking services..."
echo ""

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/check-status-script.sh" < /tmp/check-status-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_PORT='$APP_PORT' && bash /tmp/check-status-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/check-status-script.sh" < /tmp/check-status-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export APP_PORT='$APP_PORT' && bash /tmp/check-status-script.sh"
fi

echo ""

