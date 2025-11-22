# Complete Deployment Guide - Fixed Version

> **🎯 Tất cả các lỗi đã được fix và integrate vào scripts**  
> **Không cần chạy fix scripts riêng lẻ nữa!**

## 📋 Overview

Document này hướng dẫn deployment với **TẤT CẢ các fixes đã được integrate**.

## ✅ What's Fixed

Các lỗi sau đã được fix tự động trong scripts:

- ✅ Database password authentication failures
- ✅ Prisma version conflicts (downgraded to 6.x)
- ✅ Prisma schema missing DATABASE_URL
- ✅ PostgreSQL config path with wildcards
- ✅ Keycloak database connection issues
- ✅ App database connection issues
- ✅ ModelViewer TypeScript errors
- ✅ Migration vs db push issues
- ✅ SSL certificate validation
- ✅ Locale warnings

## 🚀 Quick Start - One Command Deployment

```bash
# Make sure all scripts are executable
chmod +x scripts/*.sh

# Run full deployment with all fixes
./scripts/full-deploy-fixed.sh
```

**That's it!** Script sẽ tự động:
1. Setup VPS với tất cả dependencies
2. Create databases với password fixes
3. Install Keycloak với database verification
4. Deploy Next.js app với all fixes
5. Configure Nginx

---

## 📝 Pre-Deployment Setup

### 1. Clone Repository

```bash
git clone https://github.com/nmcong/showcase-app.git
cd showcase-app
```

### 2. Install Local Dependencies

```bash
npm install
```

### 3. Configure Environment

```bash
# Copy example file
cp env.deploy.example .env.deploy

# Edit with your settings
nano .env.deploy
```

**Required Settings:**
```bash
# VPS Connection
VPS_HOST=your-vps-ip
VPS_PORT=22
VPS_USER=root
VPS_PASSWORD=your-password  # or use VPS_SSH_KEY

# Domains
APP_DOMAIN=showcase.vibytes.tech
KEYCLOAK_DOMAIN=auth.vibytes.tech

# Database Passwords
DB_PASSWORD=strong-password-here
KEYCLOAK_DB_PASSWORD=another-strong-password

# Keycloak Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin-password

# Git Repository
GIT_REPO_URL=https://github.com/yourusername/showcase-app.git
```

### 4. Setup SSH Access (if using key)

```bash
# Generate SSH key if not exists
ssh-keygen -t rsa -b 4096

# Copy to VPS
ssh-copy-id -i ~/.ssh/id_rsa.pub root@your-vps-ip

# Test connection
ssh root@your-vps-ip "echo 'SSH connection OK'"
```

---

## 🎬 Deployment Options

### Option 1: Full Automatic Deployment (Recommended)

```bash
./scripts/full-deploy-fixed.sh
```

**Includes:**
- VPS setup
- Database setup with password fixes
- Keycloak installation with DB verification
- App deployment with DB fixes
- Nginx configuration

### Option 2: Step-by-Step Deployment

If you prefer manual control:

```bash
# Step 1: Setup VPS
./scripts/setup-vps.sh

# Step 2: Setup Databases (with integrated fixes)
./scripts/setup-database.sh

# Step 3: Install Keycloak (with DB verification)
./scripts/install-keycloak.sh

# Step 4: Deploy App (with DB fixes)
./scripts/deploy-app-auto.sh

# Step 5: Setup Nginx
./scripts/setup-nginx.sh
```

---

## 🔒 SSL Certificate Setup

### If You Have SSL Certificates

**For Showcase Domain:**

1. Place certificates in `ca/showcase/`:
   ```
   ca/showcase/
   ├── private_key_showcase-vibytes-tech.txt
   ├── certificate_showcase-vibytes-tech.txt
   └── rootca_showcase-vibytes-tech.txt
   ```

2. Run SSL setup:
   ```bash
   ./scripts/setup-ssl-showcase-only.sh
   ```

**For Auth Domain (Keycloak):**

1. Place certificates in `ca/auth/`:
   ```
   ca/auth/
   ├── private_key_auth-vibytes-tech.txt
   ├── certificate_auth-vibytes-tech.txt
   └── rootca_auth-vibytes-tech.txt
   ```

2. Update and run SSL setup script

### SSL Domain Validation

If you need to validate domain for SSL provider:

```bash
# Place validation file in ca/showcase/
# e.g., DD420E628EDFB75596E4438A876F43EB.txt

# Deploy validation file
./scripts/deploy-validation.sh
```

File will be accessible at:
`http://showcase.vibytes.tech/.well-known/pki-validation/FILENAME.txt`

---

## 🔍 Verification

### Check Services Status

```bash
./scripts/check-status.sh
```

Expected output:
- ✅ Keycloak: Active and running on port 8080
- ✅ Next.js App: Online via PM2 on port 3000
- ✅ Nginx: Active and configured
- ✅ PostgreSQL: Running

### Test URLs

```bash
# Test app
curl -I http://showcase.vibytes.tech
# or
curl -I https://showcase.vibytes.tech

# Test Keycloak
curl -I http://auth.vibytes.tech
# or
curl -I https://auth.vibytes.tech
```

### Check Logs

```bash
# Next.js App logs
pm2 logs showcase-app

# Keycloak logs
sudo journalctl -u keycloak -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
```

---

## 🛠️ Post-Deployment Configuration

### 1. Configure Keycloak

1. Access Keycloak Admin Console:
   ```
   http://auth.vibytes.tech/admin/
   or
   https://auth.vibytes.tech/admin/
   ```

2. Login with credentials from `.env.deploy`:
   - Username: `KEYCLOAK_ADMIN`
   - Password: `KEYCLOAK_ADMIN_PASSWORD`

3. Create Realm:
   - Name: `showcase-realm`
   - Enabled: ON

4. Create Client:
   - Client ID: `showcase-client`
   - Client Protocol: `openid-connect`
   - Access Type: `confidential`
   - Valid Redirect URIs: `https://showcase.vibytes.tech/*`
   - Web Origins: `https://showcase.vibytes.tech`

5. Get Client Secret:
   - Go to Credentials tab
   - Copy the Secret
   - Update `.env.deploy` with `KEYCLOAK_CLIENT_SECRET`

6. Redeploy app with new secret:
   ```bash
   ./scripts/deploy-app-auto.sh
   ```

### 2. Update DNS Records

Ensure your domains point to VPS:

```bash
# Check DNS
nslookup showcase.vibytes.tech
nslookup auth.vibytes.tech

# Should return your VPS IP
```

### 3. Setup Firewall (if needed)

```bash
# SSH to VPS
ssh root@your-vps-ip

# Check UFW status
sudo ufw status

# Ensure ports are open
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
```

---

## 🔄 Updates and Redeployment

### Update Application Code

```bash
# Make changes locally
git add .
git commit -m "Your changes"
git push origin main

# Redeploy on VPS
./scripts/deploy-app-auto.sh
```

Script will:
- Pull latest code
- Install dependencies
- Rebuild application
- Restart PM2

### Update Keycloak

```bash
# Update KEYCLOAK_VERSION in .env.deploy
# Then run:
./scripts/install-keycloak.sh
```

### Update Database Schema

```bash
# Make changes to prisma/schema.prisma
# Commit and push
git push origin main

# Redeploy
./scripts/deploy-app-auto.sh
```

Script will automatically run `prisma db push` to sync schema.

---

## 📊 Monitoring

### PM2 Monitoring

```bash
# Dashboard
pm2 monit

# List apps
pm2 list

# App info
pm2 info showcase-app

# Restart
pm2 restart showcase-app

# View logs
pm2 logs showcase-app --lines 100
```

### System Resources

```bash
# CPU, Memory usage
htop

# Disk usage
df -h

# Network connections
sudo netstat -tlnp
```

---

## 🐛 Troubleshooting

If you encounter any issues:

1. **Check the troubleshooting guide:**
   ```bash
   cat docs/12-TROUBLESHOOTING.md
   ```

2. **Run status check:**
   ```bash
   ./scripts/check-status.sh
   ```

3. **Check specific logs:**
   ```bash
   # Keycloak
   ./scripts/check-keycloak-logs.sh
   
   # PM2
   pm2 logs showcase-app
   
   # Nginx
   sudo nginx -t
   sudo tail -100 /var/log/nginx/error.log
   ```

4. **Common fixes (now integrated):**
   - Database password issues → Fixed in scripts
   - Keycloak crashes → DB verification integrated
   - App deployment errors → All fixes included

---

## 📚 Additional Resources

- **Troubleshooting Guide:** [docs/12-TROUBLESHOOTING.md](./12-TROUBLESHOOTING.md)
- **VPS Deployment Guide:** [docs/04-VPS_DEPLOYMENT_GUIDE.md](./04-VPS_DEPLOYMENT_GUIDE.md)
- **Keycloak Setup:** [docs/05-KEYCLOAK_SETUP.md](./05-KEYCLOAK_SETUP.md)
- **3D Models Guide:** [docs/07-3D_MODELS_GUIDE.md](./07-3D_MODELS_GUIDE.md)

---

## ✨ Features of Fixed Deployment

### Automated Fixes

- **Database Credentials:** Automatically verified and fixed
- **Prisma Version:** Locked to 6.x, no v7 issues
- **Schema Sync:** Uses `db push` instead of migrations
- **Error Handling:** Graceful error messages
- **Idempotency:** Can run scripts multiple times safely

### Security

- **HSTS Headers:** Enabled by default
- **XSS Protection:** Configured
- **Frame Options:** Set to SAMEORIGIN
- **SSL/TLS:** Modern cipher suites
- **Firewall:** UFW configured

### Performance

- **HTTP/2:** Enabled
- **Gzip Compression:** Enabled
- **PM2 Cluster Mode:** Multiple instances
- **PostgreSQL Tuning:** Optimized for 4GB RAM
- **Keycloak JVM:** Tuned for performance

---

## 📞 Support

If you encounter issues not covered in documentation:

1. Check logs first
2. Review troubleshooting guide
3. Verify all environment variables
4. Ensure VPS has enough resources (2GB RAM minimum)

---

**Last Updated:** Nov 22, 2025  
**Version:** 2.0 - All Fixes Integrated  
**Tested On:** Ubuntu 24.04 LTS, Node.js 20.x, PostgreSQL 16, Keycloak 26.4.5

