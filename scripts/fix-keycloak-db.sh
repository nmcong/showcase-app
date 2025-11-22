#!/bin/bash

# ================================================
# Fix Keycloak Database Credentials
# ================================================

set -e

echo "================================================"
echo "Fix Keycloak Database Script"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "This script will:"
echo "  1. Reset Keycloak database user password"
echo "  2. Rebuild Keycloak configuration"
echo "  3. Restart Keycloak service"
echo ""

# Create fix script
cat > /tmp/fix-keycloak-db.sh << REMOTESCRIPT
#!/bin/bash
set -e

echo ""
echo "================================================"
echo "Fixing Keycloak Database User"
echo "================================================"

# Reset user password and ensure all permissions
sudo -u postgres psql << EOF
-- Create user if not exists, or alter password if exists
DO \\\$\\\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$KEYCLOAK_DB_USER') THEN
    CREATE USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  ELSE
    ALTER USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  END IF;
END
\\\$\\\$;

-- Create database if not exists
SELECT 'CREATE DATABASE $KEYCLOAK_DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$KEYCLOAK_DB_NAME')\gexec

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE $KEYCLOAK_DB_NAME TO $KEYCLOAK_DB_USER;

-- Connect and set schema permissions
\c $KEYCLOAK_DB_NAME
GRANT ALL ON SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $KEYCLOAK_DB_USER;
EOF

echo "✓ Database user fixed"

echo ""
echo "================================================"
echo "Testing Database Connection"
echo "================================================"

PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT 1 as test;" && echo "✓ Database connection successful!"

echo ""
echo "================================================"
echo "Updating Keycloak Configuration"
echo "================================================"

# Recreate Keycloak config
sudo tee /opt/keycloak/conf/keycloak.conf > /dev/null << KCCONF
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

sudo chown keycloak:keycloak /opt/keycloak/conf/keycloak.conf

echo "✓ Keycloak config updated"

echo ""
echo "================================================"
echo "Rebuilding and Restarting Keycloak"
echo "================================================"

# Stop Keycloak
sudo systemctl stop keycloak

# Rebuild Keycloak
cd /opt/keycloak
sudo -u keycloak \
    KEYCLOAK_ADMIN=$KEYCLOAK_ADMIN \
    KEYCLOAK_ADMIN_PASSWORD=$KEYCLOAK_ADMIN_PASSWORD \
    JAVA_OPTS="-Xms$KEYCLOAK_JVM_XMS -Xmx$KEYCLOAK_JVM_XMX" \
    bin/kc.sh build

echo "✓ Keycloak rebuilt"

# Start Keycloak
sudo systemctl start keycloak

echo ""
echo "Waiting for Keycloak to start (60 seconds)..."
sleep 60

echo ""
echo "================================================"
echo "Checking Keycloak Status"
echo "================================================"

sudo systemctl status keycloak --no-pager || true

echo ""
echo "Testing Keycloak health endpoint..."
for i in {1..10}; do
    if curl -sf http://localhost:8080/health/ready > /dev/null 2>&1; then
        echo "✓ Keycloak is ready and healthy!"
        break
    else
        echo "  Waiting... (\$i/10)"
        sleep 10
    fi
done

echo ""
echo "================================================"
echo "Fix Complete!"
echo "================================================"
echo ""
echo "Keycloak should now be accessible at:"
echo "  http://auth.vibytes.tech"
echo ""

REMOTESCRIPT

# Execute on VPS
echo "Executing fix on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/fix-keycloak-db.sh" < /tmp/fix-keycloak-db.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         export KEYCLOAK_JVM_XMS='$KEYCLOAK_JVM_XMS' && \
         export KEYCLOAK_JVM_XMX='$KEYCLOAK_JVM_XMX' && \
         bash /tmp/fix-keycloak-db.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/fix-keycloak-db.sh" < /tmp/fix-keycloak-db.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DOMAIN='$KEYCLOAK_DOMAIN' && \
         export KEYCLOAK_ADMIN='$KEYCLOAK_ADMIN' && \
         export KEYCLOAK_ADMIN_PASSWORD='$KEYCLOAK_ADMIN_PASSWORD' && \
         export KEYCLOAK_JVM_XMS='$KEYCLOAK_JVM_XMS' && \
         export KEYCLOAK_JVM_XMX='$KEYCLOAK_JVM_XMX' && \
         bash /tmp/fix-keycloak-db.sh"
fi

echo ""
echo "✓ Keycloak database fixed successfully!"
echo ""

