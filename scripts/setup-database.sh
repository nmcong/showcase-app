#!/bin/bash

# ================================================
# Database Setup Script
# ================================================
# Tạo databases và users cho application và Keycloak
# ================================================

set -e

echo "================================================"
echo "Database Setup Script"
echo "================================================"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "✗ Error: .env not found!"
    exit 1
fi

echo ""
echo "Database Configuration:"
echo "----------------------"
echo "App DB: $DB_NAME"
echo "App User: $DB_USER"
echo "Keycloak DB: $KEYCLOAK_DB_NAME"
echo "Keycloak User: $KEYCLOAK_DB_USER"
echo ""

# Create database setup script
cat > /tmp/db-setup-script.sh << REMOTESCRIPT
#!/bin/bash
set -e

# Fix locale warnings
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

echo "================================================"
echo "Creating PostgreSQL Databases and Users"
echo "================================================"

# Create App Database
sudo -u postgres psql << EOF
-- Create app user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  END IF;
END
\$\$;

-- Create app database (skip if exists)
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Connect to database and grant schema privileges
\c $DB_NAME
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;

\q
EOF

echo "✓ App database created"

# Create Keycloak Database
sudo -u postgres psql << EOF
-- Create keycloak user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$KEYCLOAK_DB_USER') THEN
    CREATE USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  END IF;
END
\$\$;

-- Create keycloak database (skip if exists)
SELECT 'CREATE DATABASE $KEYCLOAK_DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$KEYCLOAK_DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $KEYCLOAK_DB_NAME TO $KEYCLOAK_DB_USER;

-- Connect to database and grant schema privileges
\c $KEYCLOAK_DB_NAME
GRANT ALL ON SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $KEYCLOAK_DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $KEYCLOAK_DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $KEYCLOAK_DB_USER;

\q
EOF

echo "✓ Keycloak database created"

echo ""
echo "================================================"
echo "Optimizing PostgreSQL for 4GB RAM"
echo "================================================"

# Find PostgreSQL config file
PG_CONF=\$(sudo find /etc/postgresql -name postgresql.conf -type f | head -n 1)

if [ -z "\$PG_CONF" ]; then
    echo "✗ PostgreSQL config file not found, skipping optimization"
else
    echo "Found config: \$PG_CONF"
    
    # Backup original config
    sudo cp "\$PG_CONF" "\$PG_CONF.backup"
    
    # Update PostgreSQL configuration
    sudo tee -a "\$PG_CONF" > /dev/null << PGCONF

# ================================================
# Performance Tuning for 4GB RAM
# ================================================

# Memory Settings
shared_buffers = $PG_SHARED_BUFFERS
effective_cache_size = $PG_EFFECTIVE_CACHE_SIZE
maintenance_work_mem = $PG_MAINTENANCE_WORK_MEM
work_mem = $PG_WORK_MEM

# Checkpoint Settings
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100

# Connection Settings
max_connections = 100

# Logging
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = off
log_lock_waits = on

PGCONF

    # Restart PostgreSQL
    echo "Restarting PostgreSQL..."
    sudo systemctl restart postgresql
    
    echo "✓ PostgreSQL configured and restarted"
fi

echo ""
echo "================================================"
echo "Testing Database Connections"
echo "================================================"

# Test app database
PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT version();" > /dev/null && echo "✓ App database connection: OK" || echo "✗ App database connection: FAILED"

# Test keycloak database
PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT version();" > /dev/null && echo "✓ Keycloak database connection: OK" || echo "✗ Keycloak database connection: FAILED"

echo ""
echo "================================================"
echo "Database Setup Complete!"
echo "================================================"
echo ""
echo "Database Information:"
echo "  App DB: $DB_NAME (user: $DB_USER)"
echo "  Keycloak DB: $KEYCLOAK_DB_NAME (user: $KEYCLOAK_DB_USER)"
echo ""
echo "Connection strings:"
echo "  App: postgresql://$DB_USER:***@localhost:5432/$DB_NAME"
echo "  Keycloak: postgresql://$KEYCLOAK_DB_USER:***@localhost:5432/$KEYCLOAK_DB_NAME"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Executing database setup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" scp -P "$VPS_PORT" \
        /tmp/db-setup-script.sh "$VPS_USER@$VPS_HOST:/tmp/"
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash /tmp/db-setup-script.sh"
else
    scp -i "$VPS_SSH_KEY" -P "$VPS_PORT" \
        /tmp/db-setup-script.sh "$VPS_USER@$VPS_HOST:/tmp/"
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash /tmp/db-setup-script.sh"
fi

echo ""
echo "✓ Database setup completed successfully!"
echo ""
echo "Next step: Install Keycloak"
echo "  ./scripts/install-keycloak.sh"
echo ""

