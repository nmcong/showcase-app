#!/bin/bash

# ================================================
# Backup Script
# ================================================
# Backup databases và application files
# ================================================

set -e

echo "================================================"
echo "Backup Script"
echo "================================================"

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
echo "Backup timestamp: $BACKUP_DATE"
echo ""

# Create backup script
cat > /tmp/backup-script.sh << 'REMOTESCRIPT'
#!/bin/bash
set -e

BACKUP_DIR="$BACKUP_PATH/$BACKUP_DATE"
echo "Creating backup directory: $BACKUP_DIR"
sudo mkdir -p $BACKUP_DIR

echo ""
echo "================================================"
echo "Backing Up Databases"
echo "================================================"

# Backup App Database
echo "Backing up $DB_NAME..."
PGPASSWORD=$DB_PASSWORD pg_dump -h localhost -U $DB_USER $DB_NAME | \
    gzip > $BACKUP_DIR/${DB_NAME}_${BACKUP_DATE}.sql.gz
echo "✓ App database backed up"

# Backup Keycloak Database
echo "Backing up $KEYCLOAK_DB_NAME..."
PGPASSWORD=$KEYCLOAK_DB_PASSWORD pg_dump -h localhost -U $KEYCLOAK_DB_USER $KEYCLOAK_DB_NAME | \
    gzip > $BACKUP_DIR/${KEYCLOAK_DB_NAME}_${BACKUP_DATE}.sql.gz
echo "✓ Keycloak database backed up"

echo ""
echo "================================================"
echo "Backing Up Application Files"
echo "================================================"

# Backup App
echo "Backing up application..."
sudo tar -czf $BACKUP_DIR/app_${BACKUP_DATE}.tar.gz \
    -C $APP_INSTALL_PATH \
    --exclude=node_modules \
    --exclude=.next \
    --exclude=.git \
    .
echo "✓ Application files backed up"

# Backup Keycloak
echo "Backing up Keycloak configuration..."
sudo tar -czf $BACKUP_DIR/keycloak_${BACKUP_DATE}.tar.gz \
    -C $KEYCLOAK_INSTALL_PATH/conf \
    .
echo "✓ Keycloak config backed up"

# Backup Nginx
echo "Backing up Nginx configuration..."
sudo tar -czf $BACKUP_DIR/nginx_${BACKUP_DATE}.tar.gz \
    -C /etc/nginx \
    sites-available sites-enabled nginx.conf
echo "✓ Nginx config backed up"

echo ""
echo "================================================"
echo "Cleaning Up Old Backups"
echo "================================================"

# Remove backups older than retention days
echo "Removing backups older than $BACKUP_RETENTION_DAYS days..."
find $BACKUP_PATH -type d -mtime +$BACKUP_RETENTION_DAYS -exec rm -rf {} + 2>/dev/null || true
echo "✓ Old backups cleaned up"

echo ""
echo "================================================"
echo "Backup Summary"
echo "================================================"

# Calculate backup size
BACKUP_SIZE=$(du -sh $BACKUP_DIR | cut -f1)

echo "Backup location: $BACKUP_DIR"
echo "Backup size: $BACKUP_SIZE"
echo ""
echo "Backup contents:"
ls -lh $BACKUP_DIR

echo ""
echo "================================================"
echo "Backup Complete!"
echo "================================================"

REMOTESCRIPT

# Execute on VPS
echo "Creating backup on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/backup-script.sh" < /tmp/backup-script.sh
    
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export BACKUP_DATE='$BACKUP_DATE' && \
         export BACKUP_PATH='$BACKUP_PATH' && \
         export DB_NAME='$DB_NAME' && \
         export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export BACKUP_RETENTION_DAYS='$BACKUP_RETENTION_DAYS' && \
         bash /tmp/backup-script.sh"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "cat > /tmp/backup-script.sh" < /tmp/backup-script.sh
    
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" \
        "export BACKUP_DATE='$BACKUP_DATE' && \
         export BACKUP_PATH='$BACKUP_PATH' && \
         export DB_NAME='$DB_NAME' && \
         export DB_USER='$DB_USER' && \
         export DB_PASSWORD='$DB_PASSWORD' && \
         export KEYCLOAK_DB_NAME='$KEYCLOAK_DB_NAME' && \
         export KEYCLOAK_DB_USER='$KEYCLOAK_DB_USER' && \
         export KEYCLOAK_DB_PASSWORD='$KEYCLOAK_DB_PASSWORD' && \
         export APP_INSTALL_PATH='$APP_INSTALL_PATH' && \
         export KEYCLOAK_INSTALL_PATH='$KEYCLOAK_INSTALL_PATH' && \
         export BACKUP_RETENTION_DAYS='$BACKUP_RETENTION_DAYS' && \
         bash /tmp/backup-script.sh"
fi

echo ""
echo "✓ Backup completed successfully!"
echo ""
echo "To download backup to local machine:"
if [ -n "$VPS_PASSWORD" ]; then
    echo "  sshpass -p '$VPS_PASSWORD' scp -r -P $VPS_PORT $VPS_USER@$VPS_HOST:$BACKUP_PATH/$BACKUP_DATE ./backups/"
else
    echo "  scp -i $VPS_SSH_KEY -r -P $VPS_PORT $VPS_USER@$VPS_HOST:$BACKUP_PATH/$BACKUP_DATE ./backups/"
fi
echo ""

