# Troubleshooting Guide - Các Lỗi Thường Gặp và Cách Fix

> **Document này tổng hợp tất cả các lỗi đã được fix trong quá trình deployment**

## 📋 Mục lục

1. [Database Issues](#database-issues)
2. [Keycloak Issues](#keycloak-issues)
3. [Prisma Issues](#prisma-issues)
4. [SSL Certificate Issues](#ssl-certificate-issues)
5. [Next.js Build Issues](#nextjs-build-issues)
6. [Nginx Configuration Issues](#nginx-configuration-issues)

---

## 🗄️ Database Issues

### Issue 1: PostgreSQL User Password Authentication Failed

**Lỗi:**
```
FATAL: password authentication failed for user "admin"
```

**Nguyên nhân:**
- Database setup script tạo user nhưng password không được set đúng
- User đã tồn tại từ lần chạy trước với password khác
- Script `CREATE USER` fail khi user đã tồn tại

**Fix đã áp dụng:**
- Check user existence trước khi tạo
- Sử dụng `ALTER USER` để update password nếu user đã tồn tại
- Sử dụng `DO` block với conditional logic

**Code Fix (đã integrate vào `setup-database.sh`):**
```sql
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'username') THEN
    ALTER USER username WITH PASSWORD 'password';
  ELSE
    CREATE USER username WITH PASSWORD 'password';
  END IF;
END
$$;
```

---

### Issue 2: PostgreSQL Config Path với Wildcard

**Lỗi:**
```bash
cp: cannot create regular file '/etc/postgresql/*/main/postgresql.conf.backup': No such file or directory
```

**Nguyên nhân:**
- Script dùng wildcard `*` nhưng shell không expand đúng trong heredoc
- PostgreSQL version khác nhau có path khác nhau

**Fix đã áp dụng:**
- Sử dụng `find` để tìm config file chính xác
- Check file existence trước khi backup

**Code Fix (đã integrate vào `setup-database.sh`):**
```bash
# Find PostgreSQL config file
PG_CONF=$(sudo find /etc/postgresql -name postgresql.conf -type f | head -n 1)

if [ -z "$PG_CONF" ]; then
    echo "✗ PostgreSQL config file not found, skipping optimization"
else
    echo "Found config: $PG_CONF"
    sudo cp "$PG_CONF" "$PG_CONF.backup"
fi
```

---

### Issue 3: Database Already Exists Error

**Lỗi:**
```
ERROR: database "showcase_db" already exists
ERROR: role "admin" already exists
```

**Nguyên nhân:**
- Re-running deployment script
- Database đã được tạo từ lần deploy trước

**Fix đã áp dụng:**
- Check existence trước khi tạo
- Sử dụng `IF NOT EXISTS` hoặc `DO` block

**Code Fix:**
```sql
SELECT 'CREATE DATABASE dbname'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'dbname')\gexec
```

---

## 🔐 Keycloak Issues

### Issue 4: Keycloak Database Connection Failed

**Lỗi:**
```
ERROR: Failed to obtain JDBC connection
FATAL: password authentication failed for user "admin"
```

**Nguyên nhân:**
- Keycloak config có username/password cũ
- Database user password đã thay đổi nhưng Keycloak config chưa update
- Service restart mà không rebuild config

**Fix đã áp dụng:**
- Always reset database password khi restart Keycloak
- Rebuild Keycloak sau khi thay đổi config
- Verify database connection trước khi start service

**Script:** `fix-keycloak-db.sh` (đã integrate vào deployment flow)

---

### Issue 5: Keycloak Crashes on Restart

**Lỗi:**
- Service restart 20+ lần
- Status: `activating (auto-restart)`
- Exit code: 1/FAILURE

**Nguyên nhân:**
- Database credentials không match sau restart
- Config file bị overwrite với thông tin cũ
- Hostname strict mode issues sau enable SSL

**Fix đã áp dụng:**
- Fix database credentials trước khi restart
- Update config file với đúng credentials
- Set `hostname-strict=true` chỉ khi đã có SSL

---

## 📦 Prisma Issues

### Issue 6: Prisma 7.0.0 Breaking Changes

**Lỗi:**
```
Error: The datasource property `url` is no longer supported in schema files
Error code: P1012
```

**Nguyên nhân:**
- Prisma 7.0.0 đổi cú pháp, không còn support `url` trong schema
- Breaking change yêu cầu migration sang config file mới

**Fix đã áp dụng:**
- Downgrade Prisma từ 7.0.0 → 6.19.0
- Update `package.json` với version cố định

**Code Fix:**
```json
{
  "dependencies": {
    "@prisma/client": "^6.1.0",
    "prisma": "^6.1.0"
  }
}
```

---

### Issue 7: Prisma Schema Missing DATABASE_URL

**Lỗi:**
```
Error: Argument "url" is missing in data source block "db"
```

**Nguyên nhân:**
- File `schema.prisma` không có property `url` trong datasource
- File bị corrupted hoặc overwrite sai

**Fix đã áp dụng:**
- Thêm `url = env("DATABASE_URL")` vào schema
- Verify schema file trước khi deploy

**Code Fix:**
```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

---

### Issue 8: Prisma Migrate vs DB Push

**Lỗi:**
```
Error: No migration found in prisma/migrations
```

**Nguyên nhân:**
- `prisma migrate deploy` cần migration files
- Migration files không có trong production build
- Database schema cần sync without migrations

**Fix đã áp dụng:**
- Đổi từ `prisma migrate deploy` sang `prisma db push`
- Đơn giản hơn cho deployment không có migrations

**Code Fix (trong `deploy-app-auto.sh`):**
```bash
# OLD: sudo npx prisma migrate deploy
# NEW:
sudo npx prisma db push --accept-data-loss
```

---

### Issue 9: Prisma Config File for v7

**Lỗi:**
```
Module '"@prisma/client"' has no exported member 'defineConfig'
```

**Nguyên nhân:**
- File `prisma/prisma.config.ts` tồn tại (cho Prisma 7)
- Prisma 6 không support file này

**Fix đã áp dụng:**
- Xóa file `prisma/prisma.config.ts`
- Chỉ sử dụng `schema.prisma` với Prisma 6

---

## 🔒 SSL Certificate Issues

### Issue 10: Certificate and Key Mismatch

**Lỗi:**
```
SSL: error:05800074:x509 certificate routines::key values mismatch
```

**Nguyên nhân:**
- File `rootca_*.txt` là Intermediate CA cert, không phải domain cert
- Private key không match với certificate
- Thiếu domain certificate từ SSL provider

**Fix đã áp dụng:**
- Generate domain certificate (self-signed cho testing)
- Hoặc lấy domain certificate từ SSL provider
- Verify key-cert match trước khi upload

**Verification:**
```bash
# Check if key and cert match
openssl rsa -in private_key.txt -modulus -noout | openssl md5
openssl x509 -in certificate.txt -modulus -noout | openssl md5
# Both should output same MD5 hash
```

---

### Issue 11: SSL Validation File Not Accessible

**Lỗi:**
```
403 Forbidden when accessing /.well-known/pki-validation/
```

**Nguyên nhân:**
- Nginx config không serve `.well-known` directory
- File permissions không đúng
- Location block order sai

**Fix đã áp dụng:**
- Add explicit location block cho `.well-known`
- Set correct permissions (755 for dirs, 644 for files)
- Serve via HTTP (không redirect sang HTTPS)

**Code Fix:**
```nginx
server {
    listen 80;
    server_name example.com;
    
    # Allow .well-known for SSL validation
    location /.well-known/ {
        root /var/www/app/public;
        try_files $uri $uri/ =404;
    }
    
    # Redirect other traffic
    location / {
        return 301 https://$server_name$request_uri;
    }
}
```

---

## ⚛️ Next.js Build Issues

### Issue 12: ModelViewer TypeScript Errors

**Lỗi:**
```typescript
Property 'config' does not exist on type 'PresentationControlProps'
Property 'snap' does not exist on type 'Boolean'
```

**Nguyên nhân:**
- `@react-three/drei` version mới đổi API
- `PresentationControls` props không còn support `config` và `snap` object

**Fix đã áp dụng:**
- Remove `PresentationControls` component
- Simplify ModelViewer để tương thích

**Code Fix:**
```tsx
// OLD:
<PresentationControls
  config={{ mass: 2, tension: 500 }}
  snap={{ mass: 4, tension: 1500 }}
>
  <Model url={modelUrl} />
</PresentationControls>

// NEW:
<Model url={modelUrl} />
```

---

### Issue 13: Camera-controls Engine Warning

**Lỗi:**
```
npm WARN EBADENGINE package 'camera-controls@3.1.2'
required: { node: '>=22.0.0' }
current: { node: 'v20.19.5' }
```

**Nguyên nhân:**
- Package yêu cầu Node.js 22+
- VPS chạy Node.js 20.x

**Fix:**
- Warning này không ảnh hưởng functionality
- Có thể ignore hoặc upgrade Node.js sang v22

---

## 🌐 Nginx Configuration Issues

### Issue 14: HTTP/2 Not Enabled

**Nguyên nhân:**
- SSL config thiếu `http2` directive

**Fix đã áp dụng:**
```nginx
# OLD: listen 443 ssl;
# NEW:
listen 443 ssl http2;
```

---

### Issue 15: Missing Security Headers

**Fix đã áp dụng:**
```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

---

## 🔧 Script Improvements

### All Scripts Updated With:

1. **Better Error Handling**
   ```bash
   set -e  # Exit on error
   if [ condition ]; then
       # Handle error
       exit 1
   fi
   ```

2. **Existence Checks**
   ```bash
   if [ ! -f "file" ]; then
       echo "Error: file not found"
       exit 1
   fi
   ```

3. **Idempotency**
   - Scripts can be run multiple times safely
   - Check before create/modify
   - Use `ALTER` instead of `CREATE OR REPLACE`

4. **Locale Fixes**
   ```bash
   export LC_ALL=C.UTF-8
   export LANG=C.UTF-8
   ```

5. **Password Reset Logic**
   - Always use `DO` blocks with conditionals
   - `ALTER USER` for existing users
   - Verify connection after password change

---

## 📝 Pre-Deployment Checklist

Trước khi deploy, verify:

- [ ] `.env.deploy` đã được configure đúng
- [ ] Database passwords đã được set
- [ ] SSL certificates (nếu có) đã đặt trong `ca/` directories
- [ ] Prisma version là 6.x (không phải 7.x)
- [ ] `schema.prisma` có `url = env("DATABASE_URL")`
- [ ] Git repository accessible từ VPS

---

## 🚀 Updated Deployment Flow

Script order đã được optimize:

```bash
# 1. VPS Setup
./scripts/setup-vps.sh

# 2. Database Setup (with fixes)
./scripts/setup-database.sh

# 3. Keycloak Installation
./scripts/install-keycloak.sh

# 4. Fix Keycloak DB (integrated)
# Auto-runs in install script now

# 5. Deploy App
./scripts/deploy-app-auto.sh

# 6. Fix App DB (integrated)
# Auto-runs in deploy script now

# 7. Setup SSL (if have certificates)
./scripts/setup-ssl-showcase-only.sh

# 8. Nginx Setup
./scripts/setup-nginx.sh
```

---

## 📚 Related Documentation

- [Deployment Guide](./09-DEPLOYMENT.md)
- [VPS Deployment Guide](./04-VPS_DEPLOYMENT_GUIDE.md)
- [Keycloak Setup](./05-KEYCLOAK_SETUP.md)

---

**Last Updated:** Nov 22, 2025  
**Version:** 2.0 - All fixes integrated

