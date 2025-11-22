#!/bin/bash

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

echo "Checking services..."
echo ""

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "curl -s http://localhost:8080/health/ready && echo '✓ Keycloak is healthy' || echo '✗ Keycloak not ready yet'"
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" \
        "curl -s http://localhost:8080/health/ready && echo '✓ Keycloak is healthy' || echo '✗ Keycloak not ready yet'"
fi

