# Deployment Guide

This guide covers deploying the 3D Models Showcase application to various platforms.

## Prerequisites

Before deploying, ensure you have:
- ✅ Set up a PostgreSQL database
- ✅ Configured Keycloak server (if using authentication)
- ✅ Prepared 3D models in GLB/GLTF format
- ✅ Tested the application locally

## Environment Variables

Required environment variables for production:

```env
# Database
DATABASE_URL="postgresql://user:password@host:5432/database?schema=public"

# Keycloak
NEXT_PUBLIC_KEYCLOAK_URL="https://keycloak.yourdomain.com"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-secret"

# Application
NEXT_PUBLIC_APP_URL="https://yourdomain.com"
NODE_ENV="production"
```

## Deployment Options

### Option 1: Vercel (Recommended)

Vercel is the easiest way to deploy Next.js applications.

#### Steps:

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Import to Vercel**
   - Go to https://vercel.com
   - Click "Import Project"
   - Select your GitHub repository
   - Click "Import"

3. **Configure Environment Variables**
   - In Vercel dashboard, go to Settings > Environment Variables
   - Add all required environment variables
   - Make sure to add them for Production, Preview, and Development

4. **Configure Database**
   - Use Vercel Postgres, or
   - Use external PostgreSQL (Supabase, Railway, etc.)
   - Update DATABASE_URL

5. **Deploy**
   - Click "Deploy"
   - Wait for build to complete
   - Visit your deployed site

#### Automatic Deployments

- Every push to main branch triggers production deployment
- Pull requests create preview deployments
- Rollback to previous deployments in one click

#### Vercel Postgres (Optional)

```bash
# Install Vercel CLI
npm i -g vercel

# Link project
vercel link

# Create Postgres database
vercel postgres create

# Get connection string
vercel env pull .env.local
```

### Option 2: Docker

Deploy using Docker containers.

#### Create Dockerfile

```dockerfile
# Dockerfile
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build Next.js
RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

#### Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: showcase
      POSTGRES_PASSWORD: your_password
      POSTGRES_DB: showcase_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://showcase:your_password@db:5432/showcase_db
      NEXT_PUBLIC_KEYCLOAK_URL: https://keycloak.yourdomain.com
      NEXT_PUBLIC_KEYCLOAK_REALM: showcase-realm
      NEXT_PUBLIC_KEYCLOAK_CLIENT_ID: showcase-client
    depends_on:
      - db

volumes:
  postgres_data:
```

#### Deploy

```bash
# Build and run
docker-compose up -d

# Run migrations
docker-compose exec app npx prisma migrate deploy

# Seed database (optional)
docker-compose exec app npm run db:seed
```

### Option 3: Railway

Railway is a great alternative to Vercel.

#### Steps:

1. **Install Railway CLI**
   ```bash
   npm i -g @railway/cli
   railway login
   ```

2. **Initialize Project**
   ```bash
   railway init
   railway link
   ```

3. **Add PostgreSQL**
   ```bash
   railway add --database postgres
   ```

4. **Set Environment Variables**
   ```bash
   railway variables set NEXT_PUBLIC_KEYCLOAK_URL=https://your-keycloak
   railway variables set NEXT_PUBLIC_KEYCLOAK_REALM=showcase-realm
   railway variables set NEXT_PUBLIC_KEYCLOAK_CLIENT_ID=showcase-client
   ```

5. **Deploy**
   ```bash
   railway up
   ```

### Option 4: AWS (Advanced)

Deploy to AWS using Amplify or ECS.

#### AWS Amplify

1. Go to AWS Amplify Console
2. Connect your GitHub repository
3. Configure build settings
4. Add environment variables
5. Deploy

#### AWS ECS with Fargate

1. Build Docker image
2. Push to Amazon ECR
3. Create ECS task definition
4. Deploy to Fargate
5. Configure ALB and Route53

### Option 5: Self-Hosted (VPS)

Deploy to your own server (DigitalOcean, Linode, etc.)

#### Requirements:
- Ubuntu 22.04 or similar
- Node.js 20+
- PostgreSQL
- Nginx
- PM2

#### Steps:

1. **Set up server**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt install -y nodejs

   # Install PostgreSQL
   sudo apt install postgresql postgresql-contrib

   # Install Nginx
   sudo apt install nginx

   # Install PM2
   sudo npm install -g pm2
   ```

2. **Clone and build**
   ```bash
   git clone your-repo.git
   cd showcase-app
   npm install
   npx prisma generate
   npm run build
   ```

3. **Run migrations**
   ```bash
   npx prisma migrate deploy
   npm run db:seed
   ```

4. **Start with PM2**
   ```bash
   pm2 start npm --name "showcase-app" -- start
   pm2 save
   pm2 startup
   ```

5. **Configure Nginx**
   ```nginx
   # /etc/nginx/sites-available/showcase
   server {
       listen 80;
       server_name yourdomain.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

   ```bash
   sudo ln -s /etc/nginx/sites-available/showcase /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

6. **Set up SSL with Let's Encrypt**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d yourdomain.com
   ```

## Post-Deployment

### 1. Run Database Migrations

```bash
npx prisma migrate deploy
```

### 2. Seed Initial Data

```bash
npm run db:seed
```

### 3. Test the Application

- Visit your deployed URL
- Test login functionality
- Create a test model
- Submit a test comment
- Check 3D model viewer

### 4. Set Up Monitoring

**Vercel:**
- Analytics built-in
- Check deployment logs
- Set up error tracking

**Self-hosted:**
- Install monitoring tools (Prometheus, Grafana)
- Set up log aggregation
- Configure alerts

### 5. Set Up Backups

**Database backups:**
```bash
# Automated daily backups
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
```

**File backups:**
- Back up uploaded models
- Back up thumbnails
- Store backups offsite

## Performance Optimization

### 1. CDN for Static Assets

- Use Vercel's CDN (automatic)
- Or configure CloudFlare
- Or use AWS CloudFront

### 2. Database Connection Pooling

```typescript
// src/lib/prisma.ts
const prisma = new PrismaClient({
  log: ['query'],
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // Add connection pooling
  __internal: {
    engine: {
      connection_limit: 10,
    },
  },
});
```

### 3. Enable Caching

```typescript
// Add caching headers
export const revalidate = 3600; // 1 hour
```

### 4. Optimize 3D Models

- Use compressed GLB format
- Reduce polygon count
- Optimize textures
- Use LODs (Level of Detail)

## Security Checklist

- [ ] HTTPS enabled
- [ ] Environment variables secured
- [ ] Database credentials protected
- [ ] CORS configured properly
- [ ] Rate limiting enabled
- [ ] Input validation on all forms
- [ ] SQL injection protection (Prisma handles this)
- [ ] XSS protection
- [ ] CSRF protection
- [ ] Keycloak secured with strong passwords

## Troubleshooting

### Build Fails

- Check environment variables
- Verify DATABASE_URL is correct
- Run `npx prisma generate` before build

### Database Connection Issues

- Check connection string
- Verify database is accessible
- Check firewall rules
- Test with `psql` command

### 3D Models Not Loading

- Verify CORS headers
- Check model file URLs
- Ensure GLB/GLTF format
- Check file permissions

### Authentication Issues

- Verify Keycloak URL
- Check redirect URIs
- Validate client configuration
- Check network connectivity

## Scaling

### Horizontal Scaling

- Deploy multiple instances
- Use load balancer
- Session management with Redis

### Database Scaling

- Read replicas for reads
- Connection pooling
- Query optimization
- Indexing

### CDN for 3D Models

- Store models in S3/CloudFlare R2
- Serve through CDN
- Reduce origin load

## Maintenance

### Regular Updates

```bash
# Update dependencies
npm update

# Check for security vulnerabilities
npm audit

# Update Prisma
npm install @prisma/client@latest prisma@latest

# Regenerate client
npx prisma generate
```

### Database Maintenance

```bash
# Vacuum database
psql $DATABASE_URL -c "VACUUM ANALYZE;"

# Check database size
psql $DATABASE_URL -c "SELECT pg_size_pretty(pg_database_size('database_name'));"
```

## Support

For deployment issues:
- Check application logs
- Review database logs
- Check web server logs
- Contact platform support

## Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Railway Documentation](https://docs.railway.app)
- [Docker Documentation](https://docs.docker.com)
- [Nginx Documentation](https://nginx.org/en/docs/)

