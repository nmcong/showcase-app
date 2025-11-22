#!/bin/bash

# Load environment variables
if [ -f .env.deploy ]; then
    export $(cat .env.deploy | grep -v '^#' | xargs)
fi

echo "Fixing Prisma schema on VPS..."

cat > /tmp/fix-schema.sh << 'REMOTESCRIPT'
#!/bin/bash

# Backup current schema
cp /var/www/showcase-app/prisma/schema.prisma /var/www/showcase-app/prisma/schema.prisma.backup

# Add url property to datasource
sed -i 's/datasource db {/datasource db {\n  provider = "postgresql"\n  url      = env("DATABASE_URL")\n}/' /var/www/showcase-app/prisma/schema.prisma

# Remove the old provider line that's now duplicate
sed -i '/^datasource db {/,/^}/ { /^  provider = "postgresql"$/d; }' /var/www/showcase-app/prisma/schema.prisma

# Better approach: rewrite the datasource block completely
cat > /tmp/new_datasource.txt << 'EOF'
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
EOF

# Use awk to replace the datasource block
awk '
/^datasource db \{/ {
    system("cat /tmp/new_datasource.txt")
    skip=1
    next
}
/^}/ && skip {
    skip=0
    next
}
!skip
' /var/www/showcase-app/prisma/schema.prisma.backup > /var/www/showcase-app/prisma/schema.prisma

echo "Schema updated. New datasource block:"
head -15 /var/www/showcase-app/prisma/schema.prisma

REMOTESCRIPT

if [ -n "$VPS_PASSWORD" ]; then
    sshpass -p "$VPS_PASSWORD" ssh -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" "bash -s" < /tmp/fix-schema.sh
else
    ssh -i "$VPS_SSH_KEY" -p "$VPS_PORT" "$VPS_USER@$VPS_HOST" "bash -s" < /tmp/fix-schema.sh
fi

echo "✓ Schema fixed on VPS"

