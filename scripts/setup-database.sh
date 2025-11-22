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
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
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

# Set defaults for PG tuning if not set
PG_SHARED_BUFFERS=${PG_SHARED_BUFFERS:-1GB}
PG_EFFECTIVE_CACHE_SIZE=${PG_EFFECTIVE_CACHE_SIZE:-2GB}
PG_MAINTENANCE_WORK_MEM=${PG_MAINTENANCE_WORK_MEM:-256MB}
PG_WORK_MEM=${PG_WORK_MEM:-4MB}

# Execute database setup on VPS
if [ -n "$VPS_PASSWORD" ]; then
    # Using password authentication
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export LC_ALL=C.UTF-8 && \
         export LANG=C.UTF-8 && \
         export DB_NAME='$DB_NAME' && \
         export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export PG_SHARED_BUFFERS='$PG_SHARED_BUFFERS' && \
         export PG_EFFECTIVE_CACHE_SIZE='$PG_EFFECTIVE_CACHE_SIZE' && \
         export PG_MAINTENANCE_WORK_MEM='$PG_MAINTENANCE_WORK_MEM' && \
         export PG_WORK_MEM='$PG_WORK_MEM' && \
         bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "================================================"
echo "Creating PostgreSQL Databases and Users"
echo "================================================"

# Create App Database
echo "Creating app database: $DB_NAME"
sudo -u postgres psql << EOF
-- Create app user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  ELSE
    ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  END IF;
END
\$\$;

-- Create app database (skip if exists)
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

\q
EOF

# Connect and grant schema privileges
sudo -u postgres psql -d $DB_NAME << EOF
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
\q
EOF

echo "✓ App database created"

# Create Keycloak Database
echo "Creating Keycloak database: $KEYCLOAK_DB_NAME"
sudo -u postgres psql << EOF
-- Create keycloak user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$KEYCLOAK_DB_USER') THEN
    CREATE USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  ELSE
    ALTER USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  END IF;
END
\$\$;

-- Create keycloak database (skip if exists)
SELECT 'CREATE DATABASE $KEYCLOAK_DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$KEYCLOAK_DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $KEYCLOAK_DB_NAME TO $KEYCLOAK_DB_USER;

\q
EOF

# Connect and grant schema privileges
sudo -u postgres psql -d $KEYCLOAK_DB_NAME << EOF
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
echo "Verifying Database Credentials"
echo "================================================"

# Test app database connection
if PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ App database connection: OK"
else
    echo "⚠ App database connection: Failed (will retry)"
fi

# Test Keycloak database connection
if PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ Keycloak database connection: OK"
else
    echo "⚠ Keycloak database connection: Failed (will retry)"
fi

echo ""
echo "================================================"
echo "Optimizing PostgreSQL for 4GB RAM"
echo "================================================"

# Find PostgreSQL config file
PG_CONF=$(sudo find /etc/postgresql -name postgresql.conf -type f | head -n 1)

if [ -z "$PG_CONF" ]; then
    echo "✗ PostgreSQL config file not found, skipping optimization"
else
    echo "Found config: $PG_CONF"
    
    # Backup original config
    sudo cp "$PG_CONF" "$PG_CONF.backup"
    
    # Update PostgreSQL configuration
    sudo tee -a "$PG_CONF" > /dev/null << PGCONF

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

PGCONF
    
    echo "✓ PostgreSQL configuration updated"
    
    # Restart PostgreSQL
    echo "Restarting PostgreSQL..."
    sudo systemctl restart postgresql
    
    echo "✓ PostgreSQL restarted"
fi

echo ""
echo "================================================"
echo "Database Setup Complete!"
echo "================================================"
echo ""
echo "Databases created:"
echo "  • $DB_NAME (User: $DB_USER)"
echo "  • $KEYCLOAK_DB_NAME (User: $KEYCLOAK_DB_USER)"
echo ""

ENDSSH

else
    # Using SSH key authentication
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export LC_ALL=C.UTF-8 && \
         export LANG=C.UTF-8 && \
         export DB_NAME='$DB_NAME' && \
         export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export PG_SHARED_BUFFERS='$PG_SHARED_BUFFERS' && \
         export PG_EFFECTIVE_CACHE_SIZE='$PG_EFFECTIVE_CACHE_SIZE' && \
         export PG_MAINTENANCE_WORK_MEM='$PG_MAINTENANCE_WORK_MEM' && \
         export PG_WORK_MEM='$PG_WORK_MEM' && \
         bash -s" << 'ENDSSH'
#!/bin/bash
set -e

echo "================================================"
echo "Creating PostgreSQL Databases and Users"
echo "================================================"

# Create App Database
echo "Creating app database: $DB_NAME"
sudo -u postgres psql << EOF
-- Create app user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN
    CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  ELSE
    ALTER USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
  END IF;
END
\$\$;

-- Create app database (skip if exists)
SELECT 'CREATE DATABASE $DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

\q
EOF

# Connect and grant schema privileges
sudo -u postgres psql -d $DB_NAME << EOF
GRANT ALL ON SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $DB_USER;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO $DB_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO $DB_USER;
\q
EOF

echo "✓ App database created"

# Create Keycloak Database
echo "Creating Keycloak database: $KEYCLOAK_DB_NAME"
sudo -u postgres psql << EOF
-- Create keycloak user (skip if exists)
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$KEYCLOAK_DB_USER') THEN
    CREATE USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  ELSE
    ALTER USER $KEYCLOAK_DB_USER WITH PASSWORD '$KEYCLOAK_DB_PASSWORD';
  END IF;
END
\$\$;

-- Create keycloak database (skip if exists)
SELECT 'CREATE DATABASE $KEYCLOAK_DB_NAME'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$KEYCLOAK_DB_NAME')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE $KEYCLOAK_DB_NAME TO $KEYCLOAK_DB_USER;

\q
EOF

# Connect and grant schema privileges
sudo -u postgres psql -d $KEYCLOAK_DB_NAME << EOF
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
echo "Verifying Database Credentials"
echo "================================================"

# Test app database connection
if PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ App database connection: OK"
else
    echo "⚠ App database connection: Failed (will retry)"
fi

# Test Keycloak database connection
if PGPASSWORD=$KEYCLOAK_DB_PASSWORD psql -h localhost -U $KEYCLOAK_DB_USER -d $KEYCLOAK_DB_NAME -c "SELECT version();" > /dev/null 2>&1; then
    echo "✓ Keycloak database connection: OK"
else
    echo "⚠ Keycloak database connection: Failed (will retry)"
fi

echo ""
echo "================================================"
echo "Optimizing PostgreSQL for 4GB RAM"
echo "================================================"

# Find PostgreSQL config file
PG_CONF=$(sudo find /etc/postgresql -name postgresql.conf -type f | head -n 1)

if [ -z "$PG_CONF" ]; then
    echo "✗ PostgreSQL config file not found, skipping optimization"
else
    echo "Found config: $PG_CONF"
    
    # Backup original config
    sudo cp "$PG_CONF" "$PG_CONF.backup"
    
    # Update PostgreSQL configuration
    sudo tee -a "$PG_CONF" > /dev/null << PGCONF

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

PGCONF
    
    echo "✓ PostgreSQL configuration updated"
    
    # Restart PostgreSQL
    echo "Restarting PostgreSQL..."
    sudo systemctl restart postgresql
    
    echo "✓ PostgreSQL restarted"
fi

echo ""
echo "================================================"
echo "Database Setup Complete!"
echo "================================================"
echo ""
echo "Databases created:"
echo "  • $DB_NAME (User: $DB_USER)"
echo "  • $KEYCLOAK_DB_NAME (User: $KEYCLOAK_DB_USER)"
echo ""

ENDSSH

fi

echo ""
echo "================================================"
echo "✅ Database Setup Script Completed!"
echo "================================================"
