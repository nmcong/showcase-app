#!/bin/bash

# ================================================
# Fix App Database Credentials
# ================================================

set -e

echo "================================================"
echo "Fix App Database Script"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo ""
echo "This script will reset the app database user password"
echo ""

# Create fix script
cat > /tmp/fix-app-db.sh << REMOTESCRIPT
#!/bin/bash
set -e

echo ""
echo "================================================"
echo "Fixing App Database User"
echo "================================================"

# Reset user password
sudo -u postgres psql << EOF
-- Alter password for existing user
DO \\\$\\\$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN
    ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
    RAISE NOTICE 'Password updated for user: $DB_USER';
  ELSE
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
    RAISE NOTICE 'Created user: $DB_USER';
  END IF;
END
\\\$\\\$;

-- Ensure database exists
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Connect and set schema permissions
\c $DB_NAME
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
EOF

echo "✓ Database user fixed"

echo ""
echo "================================================"
echo "Testing Database Connection"
echo "================================================"

PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 1 as test;" && echo "✓ Database connection successful!"

REMOTESCRIPT

# Execute on VPS
echo "Executing fix on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/fix-app-db.sh" < /tmp/fix-app-db.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export DB_NAME='$DB_NAME' && \
         bash /tmp/fix-app-db.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/fix-app-db.sh" < /tmp/fix-app-db.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export DB_NAME='$DB_NAME' && \
         bash /tmp/fix-app-db.sh"
fi

echo ""
echo "✓ App database fixed successfully!"
echo ""

