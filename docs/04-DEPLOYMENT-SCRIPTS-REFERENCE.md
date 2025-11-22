# Deployment Scripts Guide

Hướng dẫn sử dụng các scripts tự động deploy lên VPS (không dùng Docker).

## 📦 Available Scripts (9 Essential Scripts)

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `full-deploy.sh` | 🚀 **Full deployment** | First deployment or complete re-deployment |
| `setup-vps.sh` | Setup VPS environment | Install Node.js, PostgreSQL, Nginx, Java, PM2 |
| `setup-database.sh` | Setup databases | Create databases and users |
| `install-keycloak.sh` | Install Keycloak | Install & configure Keycloak 26.4.5 |
| `deploy-app-auto.sh` | Deploy Next.js app | Deploy or update application |
| `setup-nginx.sh` | Configure Nginx | Setup reverse proxy |
| `setup-ssl-showcase-only.sh` | Setup SSL for showcase | Configure HTTPS with your certificates |
| `check-status.sh` | Check services status | Monitor all services |
| `backup.sh` | Backup data | Backup databases and files |

**All scripts include integrated fixes** - No manual fixes needed!

## 📋 Yêu Cầu

### VPS Specifications
- **CPU**: 2 cores (minimum)
- **RAM**: 4GB (optimal) - 2GB (minimum)
- **Storage**: 80GB SSD
- **OS**: Ubuntu 22.04 hoặc mới hơn
- **Network**: Public IP và domain names

### Local Machine
- **OS**: Linux, macOS, hoặc Windows với WSL/Git Bash
- **Tools**: bash, ssh, sshpass (for password authentication)
- **Git**: để clone repository

## 🚀 Quick Start

### 1. Chuẩn Bị

```bash
# Clone repository (nếu chưa có)
git clone <your-repo-url>
cd showcase-app

# Copy deployment config template
cp env.deploy.example .env.deploy

# Edit configuration
nano .env.deploy
```

### 2. Cấu Hình `.env.deploy`

Mở file `.env.deploy` và điền thông tin:

```bash
# VPS Connection
VPS_HOST=your-vps-ip          # IP hoặc domain của VPS
VPS_PORT=22                    # SSH port
VPS_USER=root                  # SSH username
VPS_PASSWORD=your-password     # SSH password (hoặc dùng SSH key)

# Domains
APP_DOMAIN=showcase.yourdomain.com
KEYCLOAK_DOMAIN=auth.yourdomain.com

# Databases
DB_PASSWORD=create-strong-password-here
KEYCLOAK_DB_PASSWORD=create-strong-password-here
KEYCLOAK_ADMIN_PASSWORD=create-admin-password-here

# Git
GIT_REPO_URL=https://github.com/yourusername/showcase-app.git
GIT_BRANCH=main

# SSL
SSL_EMAIL=your-email@example.com
```

### 3. Deploy Tự Động (One Command)

```bash
# Deploy tất cả một lần
./scripts/full-deploy.sh
```

Script này sẽ tự động:
1. ✅ Setup VPS (cài đặt Node.js, PostgreSQL, Nginx, Java)
2. ✅ Tạo databases
3. ✅ Cài đặt Keycloak 26.4.5
4. ✅ Deploy Next.js app
5. ✅ Cấu hình Nginx + SSL

**Thời gian**: ~15-20 phút

## 📝 Deploy Từng Bước

Nếu muốn control từng bước:

### Step 1: Setup VPS

```bash
./scripts/setup-vps.sh
```

Cài đặt:
- Node.js 20.x
- PostgreSQL
- Nginx
- Java 21 (for Keycloak)
- PM2
- Certbot (for SSL)

### Step 2: Setup Database

```bash
./scripts/setup-database.sh
```

Tạo:
- App database (`showcase_db`)
- Keycloak database (`keycloak_db`)
- Users với permissions
- Optimize PostgreSQL cho 4GB RAM

### Step 3: Install Keycloak

```bash
./scripts/install-keycloak.sh
```

Cài đặt:
- Keycloak 26.4.5 (standalone)
- Cấu hình với PostgreSQL
- Systemd service
- Auto-start on boot

### Step 4: Deploy Application

```bash
./scripts/deploy-app-auto.sh
```

Deploy:
- Clone/update code from Git
- Install dependencies
- Run migrations
- Build Next.js
- Start với PM2

### Step 5: Setup Nginx

```bash
./scripts/setup-nginx.sh
```

Cấu hình:
- Reverse proxy cho app và Keycloak
- SSL certificates (Let's Encrypt)
- Auto-renewal

### Step 6: Setup SSL for Showcase (Optional)

```bash
./scripts/setup-ssl-showcase-only.sh
```

**Sử dụng khi:**
- Bạn có SSL certificate riêng cho showcase domain
- Cần setup HTTPS với custom certificates

**Yêu cầu:**
- Có file certificates trong thư mục `ca/showcase/`:
  - `private_key_showcase-vibytes-tech.txt`
  - `certificate_showcase-vibytes-tech.txt`
  - `rootca_showcase-vibytes-tech.txt` (CA bundle)

Script sẽ:
- ✅ Validate certificates
- ✅ Upload certificates lên VPS
- ✅ Configure Nginx với SSL
- ✅ Setup HTTP to HTTPS redirect
- ✅ Test SSL connection

## 🔧 Scripts Khác

### Backup

```bash
# Tạo backup
./scripts/backup.sh
```

Backup:
- App database
- Keycloak database
- Application files
- Nginx configs

### Check Status

```bash
# Check all services status
./scripts/check-status.sh
```

Check:
- Keycloak service
- Next.js app (PM2)
- Nginx
- PostgreSQL

### Update App

```bash
# Update code và redeploy
./scripts/deploy-app-auto.sh
```

### View Logs

```bash
# Kết nối SSH và xem logs
ssh root@your-vps-ip

# App logs
pm2 logs showcase-app

# Keycloak logs
sudo journalctl -u keycloak -f

# Nginx logs
sudo tail -f /var/log/nginx/*.log
```

## 💡 Giải Thích Cấu Hình VPS

### Với 2 CPU | 4GB RAM | 80GB SSD:

✅ **CHẠY TỐT** mà không cần Docker!

#### Memory Allocation (4GB total):

- **PostgreSQL**: ~1.5GB
  - shared_buffers: 1GB
  - effective_cache_size: 2GB
- **Keycloak**: ~1.5GB
  - JVM Xms: 512MB
  - JVM Xmx: 1.5GB
- **Next.js App**: ~800MB
  - PM2: 2 instances × 400MB
- **System + Nginx**: ~200MB

**Total**: ~4GB (perfect fit!)

#### Why No Docker?

Docker adds overhead:
- Docker daemon: ~200MB
- Container overhead: ~50-100MB per container
- Slower startup times
- More complexity

Standalone installation:
- ✅ Less RAM usage
- ✅ Faster performance
- ✅ Easier troubleshooting
- ✅ Direct system access

## 🔍 Monitoring

### Check Services Status

```bash
# On VPS
ssh root@your-vps-ip

# Check all services
sudo systemctl status postgresql
sudo systemctl status keycloak
sudo systemctl status nginx
pm2 status

# Check resources
htop
free -h
df -h
```

### Health Checks

```bash
# App
curl https://showcase.yourdomain.com

# Keycloak
curl https://auth.yourdomain.com/health/ready

# Database
psql -h localhost -U showcase_user -d showcase_db -c "SELECT version();"
```

## 🛠️ Troubleshooting

### SSH Connection Failed

```bash
# Test SSH
ssh -v root@your-vps-ip

# If using password, install sshpass
sudo apt-get install sshpass  # Linux
brew install hudochenkov/sshpass/sshpass  # macOS
```

### Deployment Failed

```bash
# Check logs on VPS
ssh root@your-vps-ip

# Check which step failed
sudo journalctl -xe

# Re-run specific script
./scripts/setup-database.sh  # Example
```

### Service Not Starting

```bash
# On VPS
ssh root@your-vps-ip

# Check service status
sudo systemctl status keycloak
sudo systemctl status nginx

# View logs
sudo journalctl -u keycloak -n 100
pm2 logs showcase-app
```

### Database Connection Error

```bash
# Test database connection
PGPASSWORD=your-password psql -h localhost -U showcase_user -d showcase_db

# Check PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -c "\l"  # List databases
```

## 📊 Performance Tuning

### Optimize PostgreSQL

Edit on VPS: `/etc/postgresql/*/main/postgresql.conf`

```conf
# For 4GB RAM
shared_buffers = 1GB
effective_cache_size = 2GB
maintenance_work_mem = 256MB
work_mem = 4MB
```

### Optimize Keycloak

Edit: `$KEYCLOAK_INSTALL_PATH/conf/keycloak.conf`

```conf
# JVM settings in systemd service
JAVA_OPTS=-Xms512m -Xmx1536m -XX:+UseG1GC
```

### Optimize Next.js

In `scripts/deploy-app.sh`, PM2 config:

```javascript
{
  instances: 2,           // 2 instances for 4GB RAM
  max_memory_restart: '1024M'
}
```

## 🔐 Security Best Practices

### 1. Change Default Passwords

```bash
# SSH password
sudo passwd root

# Database passwords
sudo -u postgres psql
ALTER USER showcase_user WITH PASSWORD 'new-strong-password';
```

### 2. Setup SSH Key

```bash
# On local machine
ssh-keygen -t rsa -b 4096

# Copy to VPS
ssh-copy-id root@your-vps-ip

# Update .env.deploy
VPS_PASSWORD=  # Leave empty
VPS_SSH_KEY=~/.ssh/id_rsa
```

### 3. Configure Firewall

```bash
# On VPS
sudo ufw enable
sudo ufw allow 22   # SSH
sudo ufw allow 80   # HTTP
sudo ufw allow 443  # HTTPS
sudo ufw status
```

### 4. Disable Root Login (After setting up SSH key)

```bash
# On VPS
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
sudo systemctl restart sshd
```

## 📦 Environment Variables Explained

| Variable | Description | Example |
|----------|-------------|---------|
| `VPS_HOST` | IP hoặc domain của VPS | `123.45.67.89` |
| `VPS_PORT` | SSH port | `22` |
| `VPS_USER` | SSH username | `root` |
| `VPS_PASSWORD` | SSH password | `your-password` |
| `APP_DOMAIN` | Domain cho app | `showcase.example.com` |
| `KEYCLOAK_DOMAIN` | Domain cho Keycloak | `auth.example.com` |
| `DB_PASSWORD` | App database password | Strong password |
| `KEYCLOAK_DB_PASSWORD` | Keycloak DB password | Strong password |
| `KEYCLOAK_ADMIN_PASSWORD` | Keycloak admin password | Strong password |
| `GIT_REPO_URL` | Git repository URL | `https://...` |
| `GIT_BRANCH` | Git branch to deploy | `main` |
| `SSL_EMAIL` | Email for SSL certificates | `you@example.com` |
| `KEYCLOAK_JVM_XMS` | Keycloak min heap | `512m` |
| `KEYCLOAK_JVM_XMX` | Keycloak max heap | `1536m` (for 4GB RAM) |
| `PM2_INSTANCES` | PM2 cluster instances | `2` (for 2 CPU) |

## 🎯 Post-Deployment

### 1. Configure Keycloak

```bash
# Visit Keycloak Admin Console
https://auth.yourdomain.com

# Login với credentials từ .env.deploy
Username: admin
Password: <KEYCLOAK_ADMIN_PASSWORD>

# Create realm: showcase-realm
# Create client: showcase-client
# Copy client secret
```

### 2. Update App với Client Secret

```bash
# Update .env.deploy
KEYCLOAK_CLIENT_SECRET=<client-secret-from-keycloak>

# Redeploy app
./scripts/deploy-app-auto.sh
```

### 3. Test Application

```bash
# Test app
curl https://showcase.yourdomain.com

# Test login
# Visit app và click Login

# Test admin access
# Login với admin user và access Admin Panel
```

## 📞 Support

Nếu gặp vấn đề:
1. Check logs (xem phần Monitoring trên)
2. Review troubleshooting section
3. Check GitHub issues
4. Verify .env.deploy configuration

## 📚 Additional Resources

- [Complete Deployment Guide - Fixed Version](../docs/13-DEPLOYMENT-FIXED.md) - 🆕 Recommended!
- [Troubleshooting Guide](../docs/12-TROUBLESHOOTING.md) - 🆕 All errors & solutions
- [VPS Deployment Guide](../docs/04-VPS_DEPLOYMENT_GUIDE.md)
- [Keycloak Setup](../docs/05-KEYCLOAK_SETUP.md)
- [Version Compatibility](../docs/08-VERSION_COMPATIBILITY.md)
- [All Documentation](../docs/README.md)

---

**Scripts Version**: 2.0.0 (All fixes integrated)  
**Last Updated**: November 22, 2025  
**Compatible with**: Keycloak 26.4.5, Next.js 16, PostgreSQL 15+  
**9 Essential Scripts** - Cleaned & optimized

