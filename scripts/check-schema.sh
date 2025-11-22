#!/bin/bash

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

echo "Checking Prisma schema on VPS..."

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "cat /var/www/showcase-app/prisma/schema.prisma | head -15"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "cat /var/www/showcase-app/prisma/schema.prisma | head -15"
fi

