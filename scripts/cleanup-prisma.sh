#!/bin/bash

# Cleanup Prisma files from VPS

set -e

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
else
    echo "✗ Error: .env.deploy not found!"
    exit 1
fi

echo "Cleaning up Prisma files on VPS..."

# Create cleanup script
cat > /tmp/cleanup-prisma.sh << 'REMOTESCRIPT'
#!/bin/bash
cd /var/www/showcase-app

# Remove Prisma-related files
rm -f prisma.config.ts
rm -rf prisma/
rm -f src/lib/prisma.ts

echo "✓ Prisma files removed"
REMOTESCRIPT

# Execute on VPS
if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash -s" < /tmp/cleanup-prisma.sh
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" \
        "$VPS_USER@$VPS_HOST" "bash -s" < /tmp/cleanup-prisma.sh
fi

echo "✓ Cleanup completed!"

