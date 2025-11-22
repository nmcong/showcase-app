# 📘 Tổng Kết Kiến Thức Deployment

Tài liệu tổng hợp toàn bộ kiến thức và kinh nghiệm deployment 3D Models Showcase lên VPS.

---

## 📋 Mục Lục

1. [Tổng Quan Dự Án](#tổng-quan-dự-án)
2. [Kiến Trúc Hệ Thống](#kiến-trúc-hệ-thống)
3. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
4. [Quy Trình Deployment](#quy-trình-deployment)
5. [Cấu Hình Chi Tiết](#cấu-hình-chi-tiết)
6. [Scripts Deployment](#scripts-deployment)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)
9. [Maintenance & Monitoring](#maintenance--monitoring)

---

## 1. Tổng Quan Dự Án

### 1.1 Thông Tin Dự Án

- **Tên**: 3D Models Showcase
- **Mục đích**: Showcase 3D models với viewer tương tác
- **Tech Stack**:
  - Next.js 16.0.3 (React 19)
  - React Three Fiber (3D rendering)
  - Zustand (State management)
  - Tailwind CSS (Styling)
  - Lucide React (Icons)

### 1.2 Đặc Điểm Kỹ Thuật

- **Static Site**: Không cần database
- **No Authentication**: Đã remove Keycloak
- **Client-side Rendering**: 3D models load on client
- **File-based Config**: Models metadata trong `config.json`

---

## 2. Kiến Trúc Hệ Thống

### 2.1 Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Internet / Users                       │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                   Nginx (Port 80/443)                    │
│                   - Reverse Proxy                        │
│                   - SSL Termination                      │
│                   - Static File Caching                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│                PM2 Cluster (Port 3000)                   │
│  ┌─────────────────┐      ┌─────────────────┐          │
│  │  Instance 1     │      │  Instance 2     │          │
│  │  Next.js App    │      │  Next.js App    │          │
│  │  ~60MB RAM      │      │  ~60MB RAM      │          │
│  └─────────────────┘      └─────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

### 2.2 File Structure on VPS

```
/var/www/showcase-app/
├── .next/                    # Built Next.js files
├── public/                   # Static assets
│   └── models/              # 3D models & config
│       ├── config.json      # Models metadata
│       └── KatanaBamboo/    # Model assets
│           ├── bamboo_katana.glb
│           └── images/      # Preview images
├── src/                     # Source code
├── package.json
├── ecosystem.config.js      # PM2 configuration
└── .env.local              # Environment variables
```

---

## 3. Yêu Cầu Hệ Thống

### 3.1 VPS Requirements

#### Minimum (1 CPU, 2GB RAM)
```yaml
CPU: 1 core
RAM: 2GB
Storage: 20GB SSD
OS: Ubuntu 22.04+
Network: Public IP
```

**Resource Allocation:**
- Node.js: ~800MB (1 instance)
- Nginx: ~50MB
- System: ~200MB
- Available: ~950MB

#### Recommended (2 CPU, 4GB RAM)
```yaml
CPU: 2 cores
RAM: 4GB
Storage: 40GB SSD
OS: Ubuntu 22.04+
Network: Public IP + Domain
```

**Resource Allocation:**
- Node.js: ~1.5GB (2 instances)
- Nginx: ~50MB
- System: ~200MB
- Available: ~2.25GB

### 3.2 Software Requirements

**On VPS:**
- Node.js 20.x
- npm 10.x
- PM2 (process manager)
- Nginx (web server)
- Certbot (SSL certificates)
- Git

**On Local Machine:**
- bash/zsh shell
- ssh client
- sshpass (for password auth)
- git

---

## 4. Quy Trình Deployment

### 4.1 Deployment Flow

```
┌─────────────────────────────────────────────────┐
│ 1. Local Development                            │
│    - Write code                                 │
│    - Test locally (npm run dev)                 │
│    - Commit changes                             │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│ 2. Git Repository                               │
│    - Push to GitHub/GitLab                      │
│    - Branch: dev or main                        │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│ 3. VPS Setup (One-time)                         │
│    - Install Node.js, Nginx, PM2                │
│    - Configure firewall                         │
│    - Setup directories                          │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│ 4. Application Deployment                       │
│    - Clone/Pull from Git                        │
│    - Install dependencies                       │
│    - Build Next.js                              │
│    - Start with PM2                             │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│ 5. Nginx Configuration                          │
│    - Setup reverse proxy                        │
│    - Get SSL certificate                        │
│    - Enable HTTPS                               │
└────────────┬────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────┐
│ 6. Live Application                             │
│    - Accessible via HTTPS                       │
│    - Auto-restart on crash                      │
│    - Auto-renew SSL                             │
└─────────────────────────────────────────────────┘
```

### 4.2 Step-by-Step Commands

#### Initial Setup
```bash
# 1. Prepare configuration
cp env.deploy.simple.example .env.deploy
nano .env.deploy

# 2. Setup VPS (one-time)
./scripts/setup-vps-simple.sh

# 3. Deploy application
./scripts/deploy-showcase-simple.sh

# 4. Setup Nginx + SSL
./scripts/setup-nginx-simple.sh
```

#### Update Deployment
```bash
# When you have new code
git add -A
git commit -m "Update: description"
git push origin dev

# Redeploy
./scripts/deploy-showcase-simple.sh
```

---

## 5. Cấu Hình Chi Tiết

### 5.1 Environment Variables (.env.deploy)

```bash
# VPS Connection
VPS_HOST=103.82.20.169              # Your VPS IP
VPS_PORT=22                          # SSH port
VPS_USER=root                        # SSH username
VPS_PASSWORD=your-password           # Or use SSH key

# Application
APP_DOMAIN=showcase.vibytes.tech     # Your domain
APP_PORT=3000                        # App port
APP_INSTALL_PATH=/var/www/showcase-app

# Git Repository
GIT_REPO_URL=https://github.com/nmcong/showcase-app.git
GIT_BRANCH=dev                       # Your branch

# Node.js
NODE_ENV=production

# PM2 Configuration
PM2_INSTANCES=2                      # = Number of CPU cores
PM2_MAX_MEMORY=1024M                 # Max memory per instance

# SSL Configuration
SSL_EMAIL=your@email.com             # For Let's Encrypt
```

### 5.2 PM2 Configuration (ecosystem.config.js)

```javascript
module.exports = {
  apps: [{
    name: 'showcase-app',
    script: 'npm',
    args: 'start',
    cwd: '/var/www/showcase-app',
    instances: 2,                    // Cluster mode
    exec_mode: 'cluster',
    max_memory_restart: '1024M',     // Auto-restart if exceed
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/var/log/pm2/showcase-app-error.log',
    out_file: '/var/log/pm2/showcase-app-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,               // Auto-restart on crash
    watch: false,
    max_restarts: 10,
    min_uptime: '10s'
  }]
};
```

### 5.3 Nginx Configuration

```nginx
# HTTP -> HTTPS redirect
server {
    listen 80;
    server_name showcase.vibytes.tech;
    return 301 https://$host$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name showcase.vibytes.tech;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/showcase.vibytes.tech/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/showcase.vibytes.tech/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security headers
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000" always;

    # Proxy to Next.js
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files caching
    location /_next/static {
        proxy_pass http://localhost:3000;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    location /models {
        proxy_pass http://localhost:3000;
        add_header Cache-Control "public, max-age=31536000, immutable";
    }

    client_max_body_size 100M;
}
```

---

## 6. Scripts Deployment

### 6.1 Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup-vps-simple.sh` | Setup VPS environment | First-time setup |
| `deploy-showcase-simple.sh` | Deploy/update app | Deploy & updates |
| `setup-nginx-simple.sh` | Configure Nginx + SSL | After deployment |
| `full-deploy-simple.sh` | All-in-one deployment | Full automation |
| `cleanup-prisma.sh` | Remove old Prisma files | Maintenance |

### 6.2 Script Workflow

#### setup-vps-simple.sh
```bash
1. Update system packages
2. Install Node.js 20.x
3. Install PM2 globally
4. Install Nginx
5. Install Certbot (SSL)
6. Install Git
7. Create app directory
8. Configure firewall (UFW)
```

#### deploy-showcase-simple.sh
```bash
1. Clone/pull code from Git
2. Clean old files (git clean)
3. Reset to latest commit
4. Create .env.local
5. Install npm dependencies
6. Build Next.js application
7. Create PM2 ecosystem config
8. Stop old PM2 process
9. Start new PM2 process
10. Save PM2 configuration
11. Setup systemd startup
```

#### setup-nginx-simple.sh
```bash
1. Create Nginx configuration
2. Enable site
3. Test Nginx config
4. Install Certbot
5. Get SSL certificate (Let's Encrypt)
6. Setup auto-renewal
7. Reload Nginx
```

### 6.3 Script Execution Flow

```bash
# Full deployment (first time)
./scripts/full-deploy-simple.sh
    ├─> ./scripts/setup-vps-simple.sh
    ├─> ./scripts/deploy-showcase-simple.sh
    └─> ./scripts/setup-nginx-simple.sh

# Update only
./scripts/deploy-showcase-simple.sh
```

---

## 7. Troubleshooting

### 7.1 Common Issues & Solutions

#### Issue 1: Build Failed - Prisma Files
**Error:**
```
Type error: Module '"@prisma/client"' has no exported member 'defineConfig'
```

**Solution:**
```bash
# Remove Prisma files from VPS
./scripts/cleanup-prisma.sh

# Or manually
ssh root@vps-ip "cd /var/www/showcase-app && rm -rf prisma/ prisma.config.ts"
```

#### Issue 2: Git Branch Mismatch
**Error:**
```
error: src refspec main does not match any
```

**Solution:**
```bash
# Check your branch
git branch

# Update .env.deploy
GIT_BRANCH=dev  # or your actual branch name

# Redeploy
./scripts/deploy-showcase-simple.sh
```

#### Issue 3: PM2 App Not Starting
**Error:**
```
[PM2][ERROR] Application showcase-app stopped
```

**Solution:**
```bash
# SSH to VPS
ssh root@your-vps-ip

# Check logs
pm2 logs showcase-app --lines 100

# Check Node.js version
node --version  # Should be 20.x

# Restart manually
cd /var/www/showcase-app
npm run build
pm2 restart showcase-app
```

#### Issue 4: Nginx 502 Bad Gateway
**Error:**
Browser shows "502 Bad Gateway"

**Solution:**
```bash
# Check if app is running
pm2 list

# Check app port
netstat -tlnp | grep 3000

# Check Nginx logs
sudo tail -f /var/log/nginx/error.log

# Test app directly
curl http://localhost:3000
```

#### Issue 5: SSL Certificate Failed
**Error:**
```
Challenge failed for domain
```

**Solution:**
```bash
# Check DNS
nslookup your-domain.com

# Make sure port 80 is accessible
sudo ufw allow 80/tcp

# Try manual certbot
sudo certbot certonly --standalone -d your-domain.com

# Check certificate
sudo certbot certificates
```

### 7.2 Debugging Commands

```bash
# SSH to VPS
ssh root@103.82.20.169

# Check PM2 status
pm2 list
pm2 info showcase-app
pm2 logs showcase-app --lines 50

# Check system resources
free -h              # Memory usage
df -h                # Disk usage
htop                 # CPU & memory (install if needed)

# Check Nginx
sudo systemctl status nginx
sudo nginx -t        # Test configuration
sudo tail -f /var/log/nginx/error.log

# Check application
curl http://localhost:3000
curl -I https://showcase.vibytes.tech

# Check ports
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Check processes
ps aux | grep node
ps aux | grep nginx
```

---

## 8. Best Practices

### 8.1 Security

#### SSH Key Authentication
```bash
# Generate SSH key (local machine)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Copy to VPS
ssh-copy-id root@your-vps-ip

# Update .env.deploy
VPS_PASSWORD=              # Remove password
VPS_SSH_KEY=~/.ssh/id_rsa  # Add key path

# Disable password auth (VPS)
sudo nano /etc/ssh/sshd_config
# Set: PasswordAuthentication no
sudo systemctl restart sshd
```

#### Firewall Configuration
```bash
# Enable UFW
sudo ufw enable

# Allow SSH, HTTP, HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Check status
sudo ufw status verbose
```

#### Regular Updates
```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Update Node.js packages
cd /var/www/showcase-app
npm update

# Rebuild
npm run build
pm2 restart showcase-app
```

### 8.2 Performance Optimization

#### PM2 Configuration
```javascript
// For 2GB RAM VPS
PM2_INSTANCES=1
PM2_MAX_MEMORY=800M

// For 4GB RAM VPS
PM2_INSTANCES=2
PM2_MAX_MEMORY=1024M
```

#### Nginx Caching
```nginx
# Enable gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1000;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

# Browser caching for static files
location ~* \.(jpg|jpeg|png|gif|ico|css|js|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

#### Next.js Optimization
```javascript
// next.config.js
module.exports = {
  output: 'standalone',  // Minimal production build
  compress: true,         // Enable gzip
  poweredByHeader: false, // Remove X-Powered-By
  reactStrictMode: true,
};
```

### 8.3 Monitoring

#### Setup PM2 Monitoring
```bash
# Enable PM2 monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7

# Monitor real-time
pm2 monit
```

#### Log Management
```bash
# View logs
pm2 logs showcase-app

# Clear logs
pm2 flush

# Log locations
/var/log/pm2/showcase-app-error.log
/var/log/pm2/showcase-app-out.log
/var/log/nginx/access.log
/var/log/nginx/error.log
```

---

## 9. Maintenance & Monitoring

### 9.1 Daily Tasks

```bash
# Check application status
ssh root@vps-ip "pm2 list"

# Check logs for errors
ssh root@vps-ip "pm2 logs showcase-app --lines 20 --nostream"

# Check disk space
ssh root@vps-ip "df -h"
```

### 9.2 Weekly Tasks

```bash
# Update application
git pull origin dev
./scripts/deploy-showcase-simple.sh

# Check SSL certificate expiry
ssh root@vps-ip "sudo certbot certificates"

# Review logs for issues
ssh root@vps-ip "sudo tail -100 /var/log/nginx/error.log"
```

### 9.3 Monthly Tasks

```bash
# System updates
ssh root@vps-ip "sudo apt-get update && sudo apt-get upgrade -y"

# Clean old logs
ssh root@vps-ip "pm2 flush"

# Restart services
ssh root@vps-ip "pm2 restart showcase-app && sudo systemctl restart nginx"
```

### 9.4 Backup Strategy

```bash
# Backup script
#!/bin/bash
BACKUP_DIR="/var/backups/showcase"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup application files
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /var/www/showcase-app

# Backup Nginx configs
tar -czf $BACKUP_DIR/nginx_$DATE.tar.gz /etc/nginx/sites-available

# Keep only last 7 backups
find $BACKUP_DIR -type f -mtime +7 -delete
```

---

## 10. Kinh Nghiệm Thực Tế

### 10.1 Lessons Learned

1. **Always commit before deploy**
   - Đảm bảo code đã commit và push lên Git
   - VPS sẽ pull code mới nhất từ Git repository

2. **Check branch name**
   - Đảm bảo `GIT_BRANCH` trong `.env.deploy` đúng
   - Mặc định là `main`, nhưng project này dùng `dev`

3. **Remove old files**
   - Xóa hết các file liên quan đến Prisma/database
   - Git clean để tránh file cũ conflict

4. **Test build locally first**
   - Chạy `npm run build` trên local trước
   - Fix hết lỗi trước khi deploy

5. **Monitor after deployment**
   - Check logs ngay sau khi deploy: `pm2 logs`
   - Test website trong vài phút đầu

### 10.2 Common Mistakes

❌ **Không push code lên Git**
```bash
# Wrong: Deploy without pushing
./scripts/deploy-showcase-simple.sh

# Right: Push first
git push origin dev
./scripts/deploy-showcase-simple.sh
```

❌ **Sai branch trong .env.deploy**
```bash
# Wrong
GIT_BRANCH=main  # But your code is in 'dev'

# Right
GIT_BRANCH=dev
```

❌ **Quên update SSL email**
```bash
# Wrong
SSL_EMAIL=your-email@example.com

# Right
SSL_EMAIL=real@email.com
```

### 10.3 Performance Metrics

**Build Time:**
- Local: ~2-3 seconds
- VPS (2GB RAM): ~13-15 seconds
- VPS (4GB RAM): ~10-12 seconds

**Deployment Time:**
- First deployment: ~5-10 minutes
- Update deployment: ~2-5 minutes

**Application Performance:**
- Startup time: <3 seconds
- Memory per instance: ~60MB
- CPU usage: <5% (idle)

---

## 11. Quick Reference

### 11.1 Essential Commands

```bash
# Deploy
./scripts/deploy-showcase-simple.sh

# Check status
ssh root@vps-ip "pm2 list && sudo systemctl status nginx"

# View logs
ssh root@vps-ip "pm2 logs showcase-app"

# Restart app
ssh root@vps-ip "pm2 restart showcase-app"

# Test SSL
curl -I https://showcase.vibytes.tech
```

### 11.2 Important Paths

```
VPS:
  - App: /var/www/showcase-app
  - Logs: /var/log/pm2/
  - Nginx: /etc/nginx/sites-available/showcase
  - SSL: /etc/letsencrypt/live/your-domain/

Local:
  - Config: .env.deploy
  - Scripts: scripts/
  - Docs: docs/
```

### 11.3 Contact & Support

- **Project**: https://github.com/nmcong/showcase-app
- **Domain**: https://showcase.vibytes.tech
- **VPS**: 103.82.20.169

---

## 12. Changelog

### Version 1.0.0 (2025-11-22)

**Initial Deployment:**
- ✅ Removed Prisma/Database dependencies
- ✅ Removed Keycloak authentication
- ✅ Created simplified deployment scripts
- ✅ Deployed to VPS successfully
- ✅ Updated UI with Lucide icons
- ✅ Fixed all TypeScript errors
- ✅ PM2 cluster mode working
- ✅ Application running on production

**Commits:**
- `937db33` - Deploy: Remove Prisma, update UI with Lucide icons
- `5225cbf` - Previous stable version

---

**Document Version**: 1.0.0  
**Last Updated**: November 22, 2025  
**Author**: AI Assistant  
**Project**: 3D Models Showcase

