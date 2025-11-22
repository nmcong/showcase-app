# Environment Files Guide

## 📋 Overview

Project này sử dụng **2 loại environment files riêng biệt** cho mục đích khác nhau:

```
.env.local       → Local development (Next.js app)
.env.deploy      → VPS deployment (Deployment scripts)
```

## 🎯 Tại Sao Tách Biệt?

### ✅ Lợi Ích

1. **Rõ ràng và dễ quản lý**
   - Local config không lẫn với deployment config
   - Dễ dàng chia sẻ với team members

2. **Bảo mật tốt hơn**
   - Deployment credentials tách riêng
   - Không vô tình commit sensitive info

3. **Linh hoạt**
   - Có thể có nhiều `.env.deploy.*` cho nhiều servers
   - `.env.local` giữ nguyên khi switch environments

## 📁 Chi Tiết Từng File

### 1. `.env.local` - Local Development

**Mục đích**: Chạy Next.js app trên máy local

**Được dùng bởi**:
- `npm run dev`
- `npm run build`
- `npm start`
- Next.js app runtime

**Nội dung**:
```bash
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/showcase_db"

# Keycloak (local hoặc dev server)
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="your-client-secret"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

**Tạo file**:
```bash
# Copy từ example (nếu có)
cp .env.local.example .env.local

# Hoặc tạo mới
nano .env.local
```

---

### 2. `.env.deploy` - VPS Deployment

**Mục đích**: Deploy và quản lý application trên VPS

**Được dùng bởi**:
- `./scripts/full-deploy.sh`
- `./scripts/deploy-app-auto.sh`
- `./scripts/setup-vps.sh`
- `./scripts/setup-database.sh`
- `./scripts/install-keycloak.sh`
- `./scripts/setup-nginx.sh`
- `./scripts/setup-ssl-showcase-only.sh`
- `./scripts/check-status.sh`
- `./scripts/backup.sh`

**Nội dung**:
```bash
# ================================================
# VPS SSH Connection
# ================================================
VPS_HOST=your-vps-ip
VPS_PORT=22
VPS_USER=root
VPS_PASSWORD=your-password

# ================================================
# Domains
# ================================================
APP_DOMAIN=showcase.yourdomain.com
KEYCLOAK_DOMAIN=auth.yourdomain.com

# ================================================
# Database Configuration (for VPS)
# ================================================
DB_HOST=localhost
DB_PORT=5432
DB_NAME=showcase_db
DB_USER=showcase_user
DB_PASSWORD=your_db_password

# ================================================
# Keycloak Database (for VPS)
# ================================================
KEYCLOAK_DB_HOST=localhost
KEYCLOAK_DB_PORT=5432
KEYCLOAK_DB_NAME=keycloak_db
KEYCLOAK_DB_USER=keycloak_user
KEYCLOAK_DB_PASSWORD=your_keycloak_db_password

# ================================================
# Keycloak Admin
# ================================================
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=your_admin_password

# ================================================
# Git Repository
# ================================================
GIT_REPO_URL=https://github.com/yourusername/showcase-app.git
GIT_BRANCH=main

# ================================================
# Application
# ================================================
APP_PORT=3000
NODE_ENV=production

# ================================================
# Next.js Environment (được tạo trên VPS)
# ================================================
DATABASE_URL=postgresql://showcase_user:your_db_password@localhost:5432/showcase_db
NEXT_PUBLIC_KEYCLOAK_URL=http://auth.yourdomain.com
NEXT_PUBLIC_KEYCLOAK_REALM=showcase-realm
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID=showcase-client
KEYCLOAK_CLIENT_SECRET=your-client-secret
NEXT_PUBLIC_APP_URL=http://showcase.yourdomain.com

# ================================================
# SSL (Optional)
# ================================================
SSL_EMAIL=your-email@example.com

# ================================================
# System Configuration
# ================================================
KEYCLOAK_JVM_XMS=512m
KEYCLOAK_JVM_XMX=1536m
PM2_INSTANCES=2
```

**Tạo file**:
```bash
# Copy từ example
cp env.deploy.example .env.deploy

# Edit với thông tin thực tế
nano .env.deploy
```

---

## 🔄 Workflow

### Local Development

```bash
# 1. Setup local environment
cp .env.local.example .env.local
nano .env.local  # Điền config

# 2. Run app
npm run dev

# App chạy tại: http://localhost:3000
```

### VPS Deployment

```bash
# 1. Setup deployment config
cp env.deploy.example .env.deploy
nano .env.deploy  # Điền VPS credentials và config

# 2. Deploy
./scripts/full-deploy.sh

# 3. Update code sau này
git push origin main
./scripts/deploy-app-auto.sh
```

---

## 🔒 Security & .gitignore

Cả hai files đều được ignore trong Git:

```gitignore
# env files
.env*.local
.env
.env.deploy
```

**⚠️ KHÔNG BAO GIỜ commit những files này lên Git!**

---

## 📊 So Sánh

| Feature | `.env.local` | `.env.deploy` |
|---------|-------------|---------------|
| **Purpose** | Local development | VPS deployment |
| **Used by** | Next.js app | Deployment scripts |
| **Contains** | App config | VPS credentials + App config |
| **Scope** | Developer machine | Production server |
| **Created** | Manually by developer | Manually by developer |
| **Updated** | When local config changes | When deployment config changes |

---

## 🎓 Examples

### Example 1: Chạy Local với Keycloak Local

`.env.local`:
```bash
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/showcase_dev"
NEXT_PUBLIC_KEYCLOAK_URL="http://localhost:8080"
NEXT_PUBLIC_KEYCLOAK_REALM="showcase-realm"
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID="showcase-client"
KEYCLOAK_CLIENT_SECRET="dev-secret"
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

### Example 2: Deploy lên Production VPS

`.env.deploy`:
```bash
# VPS Connection
VPS_HOST=123.45.67.89
VPS_PORT=22
VPS_USER=root
VPS_PASSWORD=secure-password

# Production Domains
APP_DOMAIN=showcase.vibytes.tech
KEYCLOAK_DOMAIN=auth.vibytes.tech

# Database
DB_PASSWORD=strong-db-password
KEYCLOAK_DB_PASSWORD=strong-keycloak-password

# Git
GIT_REPO_URL=https://github.com/yourname/showcase-app.git
GIT_BRANCH=main

# Production URLs (for .env.local on VPS)
DATABASE_URL=postgresql://showcase_user:strong-db-password@localhost:5432/showcase_db
NEXT_PUBLIC_KEYCLOAK_URL=http://auth.vibytes.tech
NEXT_PUBLIC_KEYCLOAK_REALM=showcase-realm
NEXT_PUBLIC_KEYCLOAK_CLIENT_ID=showcase-client
NEXT_PUBLIC_APP_URL=http://showcase.vibytes.tech
```

---

## 📝 Common Tasks

### Task 1: Thêm Environment Variable Mới

**Cho local:**
```bash
# Edit .env.local
nano .env.local
# Thêm: NEW_VAR=value

# Restart app
npm run dev
```

**Cho production:**
```bash
# Edit .env.deploy
nano .env.deploy
# Thêm variable vào phần "Next.js Environment"

# Re-deploy
./scripts/deploy-app-auto.sh
```

### Task 2: Thay Đổi Database Password

**Local:**
```bash
nano .env.local
# Update DATABASE_URL
```

**Production:**
```bash
# 1. Update .env.deploy
nano .env.deploy
# Update DB_PASSWORD và DATABASE_URL

# 2. Re-deploy
./scripts/deploy-app-auto.sh
```

### Task 3: Nhiều Environments

Bạn có thể có nhiều deployment configs:

```bash
.env.deploy.production   # Production server
.env.deploy.staging      # Staging server
.env.deploy.dev          # Dev server
```

Sử dụng:
```bash
# Deploy to staging
cp .env.deploy.staging .env.deploy
./scripts/full-deploy.sh

# Deploy to production
cp .env.deploy.production .env.deploy
./scripts/full-deploy.sh
```

---

## ❓ FAQ

### Q: Tôi có thể dùng chỉ 1 file `.env` được không?

**A**: Có thể, nhưng không recommended vì:
- Lẫn lộn giữa local và deployment config
- Dễ vô tình commit sensitive deployment info
- Khó quản lý khi có nhiều environments

### Q: File nào được commit lên Git?

**A**: Không file nào! Chỉ commit:
- `.env.local.example` (nếu có)
- `env.deploy.example`

### Q: Deployment scripts tạo `.env.local` trên VPS như thế nào?

**A**: Scripts đọc từ `.env.deploy` và tự động tạo `.env.local` trên VPS với config phù hợp.

### Q: Tôi muốn test production config trên local?

**A**: Copy values từ `.env.deploy` sang `.env.local`:
```bash
# Extract production values
nano .env.deploy  # Copy các NEXT_PUBLIC_* và DATABASE_URL

# Paste vào local
nano .env.local
```

---

## 🎯 Best Practices

1. ✅ **Luôn dùng example files**
   ```bash
   cp env.deploy.example .env.deploy
   ```

2. ✅ **Không commit actual env files**
   - Verify: `git status` không hiện `.env*`

3. ✅ **Dùng strong passwords**
   - Đặc biệt cho `.env.deploy`

4. ✅ **Backup `.env.deploy`**
   - Lưu ở nơi an toàn (password manager, encrypted storage)

5. ✅ **Document custom variables**
   - Update example files khi thêm variables mới

6. ✅ **Review trước khi deploy**
   ```bash
   # Check config trước deploy
   cat .env.deploy | grep -v "PASSWORD"
   ```

---

## 📚 Related Documentation

- [Complete Deployment Guide](./docs/13-DEPLOYMENT-FIXED.md)
- [Troubleshooting Guide](./docs/12-TROUBLESHOOTING.md)
- [Scripts README](./scripts/README.md)

---

**Last Updated**: November 22, 2025  
**Applies to**: Project v2.0.0+

