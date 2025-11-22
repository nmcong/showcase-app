#!/bin/bash

# ================================================
# Check Keycloak Logs Script
# ================================================

set -e

echo "================================================"
echo "Keycloak Logs Check"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

# Create check script
cat > /tmp/check-keycloak-logs.sh << 'REMOTESCRIPT'
#!/bin/bash

echo ""
echo "================================================"
echo "Keycloak Service Status"
echo "================================================"
sudo systemctl status keycloak --no-pager -l

echo ""
echo "================================================"
echo "Last 50 lines of Keycloak logs"
echo "================================================"
sudo journalctl -u keycloak -n 50 --no-pager

echo ""
echo "================================================"
echo "Checking Keycloak configuration"
echo "================================================"
echo "Keycloak config file:"
cat /opt/keycloak/conf/keycloak.conf || echo "Config file not found"

echo ""
echo "================================================"
echo "Testing Database Connection"
echo "================================================"
PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT 1;" || echo "✗ Database connection failed"

REMOTESCRIPT

# Execute on VPS
if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/check-keycloak-logs.sh" < /tmp/check-keycloak-logs.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         bash /tmp/check-keycloak-logs.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/check-keycloak-logs.sh" < /tmp/check-keycloak-logs.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         bash /tmp/check-keycloak-logs.sh"
fi

echo ""

