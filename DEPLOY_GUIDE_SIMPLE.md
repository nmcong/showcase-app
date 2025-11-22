# 🚀 Hướng Dẫn Deploy Showcase Đơn Giản

Hướng dẫn deploy 3D Models Showcase lên VPS (không cần database, không cần Keycloak).

## 📋 Yêu Cầu

### VPS
- **CPU**: 1-2 cores
- **RAM**: 2GB minimum (4GB khuyến nghị)
- **Storage**: 20GB
- **OS**: Ubuntu 22.04 hoặc mới hơn
- **Network**: Public IP và domain

### Local Machine
- **OS**: Linux, macOS, hoặc Windows với WSL/Git Bash
- **Tools**: bash, ssh, sshpass (nếu dùng password authentication)

## 🎯 Quick Start

### 1. Chuẩn Bị File Cấu Hình

```bash
# Copy file mẫu
cp env.deploy.simple.example .env.deploy

# Chỉnh sửa file cấu hình
nano .env.deploy
```

### 2. Điền Thông Tin VPS

Mở `.env.deploy` và điền thông tin:

```bash
# VPS Connection
VPS_HOST=123.456.789.0        # IP hoặc domain của VPS
VPS_PORT=22
VPS_USER=root
VPS_PASSWORD=your-password     # Hoặc dùng SSH key

# Application
APP_DOMAIN=showcase.yourdomain.com
APP_PORT=3000
APP_INSTALL_PATH=/var/www/showcase-app

# Git Repository
GIT_REPO_URL=https://github.com/yourusername/showcase-app.git
GIT_BRANCH=main

# Node.js
NODE_ENV=production

# PM2 Settings
PM2_INSTANCES=2                # Số lượng instances (= số CPU cores)
PM2_MAX_MEMORY=1024M

# SSL Email (cho Let's Encrypt)
SSL_EMAIL=your@email.com
```

### 3. Deploy Tự Động (One Command)

```bash
# Cho phép chạy scripts
chmod +x scripts/*.sh

# Deploy tất cả một lần (15-20 phút)
./scripts/full-deploy-simple.sh
```

Script này sẽ tự động:
1. ✅ Cài đặt Node.js, Nginx, PM2
2. ✅ Clone code từ Git
3. ✅ Build Next.js application
4. ✅ Start app với PM2
5. ✅ Cấu hình Nginx + SSL (Let's Encrypt)

## 📝 Deploy Từng Bước (Optional)

Nếu muốn kiểm soát từng bước:

### Bước 1: Setup VPS

```bash
./scripts/setup-vps-simple.sh
```

Cài đặt:
- Node.js 20.x
- Nginx
- PM2
- Certbot (cho SSL)
- Git

### Bước 2: Deploy Application

```bash
./scripts/deploy-showcase-simple.sh
```

Deploy:
- Clone/update code
- Install dependencies
- Build Next.js
- Start với PM2

### Bước 3: Setup Nginx + SSL

```bash
./scripts/setup-nginx-simple.sh
```

Cấu hình:
- Reverse proxy cho Next.js app
- SSL certificate (Let's Encrypt)
- Auto-renewal SSL

## 🔄 Update Application

Khi có code mới:

```bash
# Chỉ cần chạy lại deploy script
./scripts/deploy-showcase-simple.sh
```

Script sẽ:
1. Pull code mới từ Git
2. Install dependencies mới (nếu có)
3. Build lại
4. Restart app

## 🔍 Kiểm Tra & Monitor

### Check Services

```bash
# Kết nối SSH
ssh root@your-vps-ip

# Check PM2 app
pm2 list
pm2 logs showcase-app
pm2 monit

# Check Nginx
sudo systemctl status nginx
sudo nginx -t

# Check SSL
sudo certbot certificates
```

### View Logs

```bash
# App logs
pm2 logs showcase-app

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Check Application

```bash
# Test app
curl https://showcase.yourdomain.com

# Check SSL
curl -I https://showcase.yourdomain.com
```

## 🛠️ Troubleshooting

### SSH Connection Failed

```bash
# Test SSH connection
ssh -v root@your-vps-ip

# Nếu dùng password, cài sshpass
# Ubuntu/Debian
sudo apt-get install sshpass

# macOS
brew install hudochenkov/sshpass/sshpass
```

### App Not Starting

```bash
# SSH vào VPS
ssh root@your-vps-ip

# Check PM2
pm2 list
pm2 logs showcase-app --lines 100

# Restart app
pm2 restart showcase-app

# Nếu vẫn lỗi, xem logs chi tiết
cd /var/www/showcase-app
npm run build  # Test build local
```

### Nginx Error

```bash
# Test Nginx config
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### SSL Certificate Error

```bash
# Check certificates
sudo certbot certificates

# Renew manually
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

### Out of Memory

Nếu VPS chỉ có 2GB RAM:

```bash
# Edit .env.deploy
PM2_INSTANCES=1              # Giảm số instances
PM2_MAX_MEMORY=800M          # Giảm max memory

# Redeploy
./scripts/deploy-showcase-simple.sh
```

## 📊 Resource Usage

### VPS với 2 CPU | 2GB RAM:

- **Node.js App**: ~800MB (2 instances)
- **Nginx**: ~50MB
- **System**: ~200MB
- **Available**: ~950MB

### VPS với 2 CPU | 4GB RAM:

- **Node.js App**: ~1.5GB (2 instances)
- **Nginx**: ~50MB
- **System**: ~200MB
- **Available**: ~2.25GB

## 🔐 Security Best Practices

### 1. Đổi SSH Password

```bash
# SSH vào VPS
ssh root@your-vps-ip

# Đổi password
passwd
```

### 2. Setup SSH Key (Khuyến nghị)

```bash
# Trên máy local
ssh-keygen -t rsa -b 4096

# Copy key lên VPS
ssh-copy-id root@your-vps-ip

# Update .env.deploy
VPS_PASSWORD=              # Bỏ password
VPS_SSH_KEY=~/.ssh/id_rsa  # Dùng SSH key
```

### 3. Configure Firewall

```bash
# Đã tự động setup trong script, nhưng có thể check
ssh root@your-vps-ip
sudo ufw status

# Nếu cần mở thêm port
sudo ufw allow <port>/tcp
```

## 📞 Support

### Check Status Script

Tạo file `scripts/check-status-simple.sh`:

```bash
#!/bin/bash
ssh root@your-vps-ip "pm2 list && sudo systemctl status nginx && sudo certbot certificates"
```

### Backup Script

Tạo file `scripts/backup-simple.sh`:

```bash
#!/bin/bash
ssh root@your-vps-ip "cd /var/www/showcase-app && tar -czf /tmp/showcase-backup-$(date +%Y%m%d).tar.gz ."
scp root@your-vps-ip:/tmp/showcase-backup-*.tar.gz ./backups/
```

## 🎯 Deployment Checklist

- [ ] Copy `env.deploy.simple.example` to `.env.deploy`
- [ ] Điền đầy đủ thông tin VPS
- [ ] Điền Git repository URL
- [ ] Điền domain và email cho SSL
- [ ] Commit và push code lên Git
- [ ] Chạy `./scripts/full-deploy-simple.sh`
- [ ] Đợi 15-20 phút cho deployment hoàn tất
- [ ] Test app tại `https://your-domain.com`
- [ ] Check logs: `pm2 logs showcase-app`
- [ ] Test SSL: `curl -I https://your-domain.com`

## 📚 Additional Info

- **Build time**: ~2-3 phút
- **Deploy time**: ~15-20 phút (lần đầu)
- **Update time**: ~5-10 phút
- **SSL renewal**: Tự động (certbot)
- **App restart**: Tự động (PM2)

---

**Version**: 1.0.0  
**Last Updated**: November 22, 2025  
**Compatible with**: Next.js 16, Node.js 20.x, Ubuntu 22.04+

