# Quick Start Guide

## 🚀 Bắt Đầu Nhanh

### Option 1: Local Development

```bash
# 1. Install dependencies
npm install

# 2. Setup local environment
cp .env.local.example .env.local
nano .env.local  # Điền DATABASE_URL, KEYCLOAK_URL, etc.

# 3. Setup database
npx prisma generate
npx prisma db push

# 4. Run dev server
npm run dev
```

Mở: http://localhost:3000

---

### Option 2: VPS Deployment

```bash
# 1. Setup deployment config
cp env.deploy.example .env.deploy
nano .env.deploy  # Điền VPS credentials, domains, passwords

# 2. Deploy everything
chmod +x scripts/*.sh
./scripts/full-deploy.sh
```

Sau ~15-20 phút, app sẽ chạy trên VPS của bạn!

---

## 📋 Environment Files

Project này dùng **2 env files riêng biệt**:

| File | Purpose | Used By |
|------|---------|---------|
| `.env.local` | **Local development** | Next.js app trên máy local |
| `.env.deploy` | **VPS deployment** | Deployment scripts |

**Chi tiết**: Xem [ENV-FILES-GUIDE.md](./ENV-FILES-GUIDE.md)

---

## 🔄 Update Code Trên VPS

```bash
# Trên máy local
git add .
git commit -m "Your changes"
git push origin main

# Deploy lên VPS
./scripts/deploy-app-auto.sh
```

---

## 📚 Documentation

- **[ENV-FILES-GUIDE.md](./ENV-FILES-GUIDE.md)** - Chi tiết về env files
- **[scripts/README.md](./scripts/README.md)** - Deployment scripts guide
- **[docs/13-DEPLOYMENT-FIXED.md](./docs/13-DEPLOYMENT-FIXED.md)** - Complete deployment guide
- **[docs/12-TROUBLESHOOTING.md](./docs/12-TROUBLESHOOTING.md)** - Troubleshooting guide

---

## 🎯 Common Commands

```bash
# Local development
npm run dev              # Start dev server
npm run build            # Build production
npm start                # Run production build

# VPS deployment
./scripts/full-deploy.sh              # Full deployment
./scripts/deploy-app-auto.sh          # Update app code
./scripts/check-status.sh             # Check services status
./scripts/setup-ssl-showcase-only.sh  # Setup SSL

# Database
npx prisma studio        # Open Prisma Studio
npx prisma db push       # Sync schema (dev)
npx prisma generate      # Generate client
```

---

## ❓ Need Help?

1. Check [ENV-FILES-GUIDE.md](./ENV-FILES-GUIDE.md) for env files questions
2. Check [docs/12-TROUBLESHOOTING.md](./docs/12-TROUBLESHOOTING.md) for errors
3. Check [scripts/README.md](./scripts/README.md) for deployment help
4. Open an issue on GitHub

---

**Version**: 2.0.0  
**Last Updated**: November 22, 2025

