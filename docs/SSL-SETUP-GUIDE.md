# SSL Certificate Setup Guide - Sectigo

Hướng dẫn chi tiết setup SSL certificates từ Sectigo cho cả 2 subdomains: `showcase.vibytes.tech` và `auth.vibytes.tech`.

## 📋 Tổng Quan

Project sử dụng SSL certificates từ **Sectigo** (hoặc nhà cung cấp SSL khác) để bảo mật:
- **showcase.vibytes.tech** - Next.js Application
- **auth.vibytes.tech** - Keycloak Authentication Server

## 🔐 Quy Trình SSL Setup

### **Phase 1: Chuẩn Bị**

#### 1.1 Mua SSL Certificate

1. Truy cập nhà cung cấp SSL (Sectigo, Let's Encrypt, etc.)
2. Mua certificate cho domain của bạn
3. Nhận các file:
   - Private Key
   - Domain Certificate
   - CA Bundle (Root CA + Intermediate CA)

#### 1.2 Tổ Chức Files

Lưu certificates vào đúng thư mục:

```bash
ca/
├── showcase/
│   ├── private_key_showcase-vibytes-tech.txt
│   ├── certificate_showcase-vibytes-tech.txt
│   ├── rootca_showcase-vibytes-tech.txt
│   └── [validation-file].txt                 # File validation từ Sectigo
├── auth/
│   ├── private_key_auth-vibytes-tech.txt
│   ├── certificate_auth-vibytes-tech.txt
│   ├── rootca_auth-vibytes-tech.txt
│   └── [validation-file].txt                 # File validation từ Sectigo
└── README.md
```

---

### **Phase 2: Domain Validation**

Sectigo (và hầu hết SSL providers) yêu cầu **verify domain ownership** trước khi issue certificate.

#### 2.1 HTTP-01 Challenge Method

**Quy trình:**

1. **Nhận validation file** từ Sectigo (thường là file `.txt` có tên hash)
   - Example: `5A3B7D292F9DD1E4EC95ADA3752C9D8F.txt`

2. **Deploy validation file** lên VPS
   - File phải accessible tại: `http://yourdomain/.well-known/pki-validation/[filename].txt`

3. **Sectigo verify** bằng cách truy cập URL đó

4. **Sau 5-30 phút**, domain được validate và certificate sẵn sàng download

#### 2.2 Deploy Validation File

**Cho Showcase Domain:**

```bash
# 1. Đặt validation file vào thư mục
cp [validation-file].txt ca/showcase/

# 2. Deploy lên VPS
./scripts/deploy-validation.sh
```

Script sẽ:
- Upload validation file lên VPS
- Tạo thư mục `/var/www/showcase-app/public/.well-known/pki-validation/`
- Configure Nginx để serve file này
- Test accessibility

**Cho Auth Domain (Keycloak):**

```bash
# 1. Đặt validation file vào thư mục
cp [validation-file].txt ca/auth/

# 2. Deploy lên VPS
./scripts/deploy-validation-auth.sh
```

#### 2.3 Verify Validation File

Test từ internet:

```bash
# Showcase
curl http://showcase.vibytes.tech/.well-known/pki-validation/[filename].txt

# Auth
curl http://auth.vibytes.tech/.well-known/pki-validation/[filename].txt
```

**Expected:** HTTP 200 với content là hash string

#### 2.4 Validate trên Sectigo

1. Login vào trang quản lý SSL của Sectigo
2. Tìm order certificate của bạn
3. Click **"Validate Domain"** hoặc **"Check Validation"**
4. Chờ 5-30 phút

#### 2.5 Download Certificate

Sau khi validation thành công:

1. Quay lại trang quản lý Sectigo
2. Sẽ xuất hiện nút **"Download Certificate"**
3. Download và lưu:
   - `certificate_showcase-vibytes-tech.txt` (hoặc `certificate_auth-vibytes-tech.txt`)
   - Lưu vào đúng thư mục `ca/showcase/` hoặc `ca/auth/`

---

### **Phase 3: SSL Setup**

#### 3.1 Setup SSL cho Showcase Domain

**Kiểm tra files:**

```bash
ls -la ca/showcase/
# Phải có:
# - private_key_showcase-vibytes-tech.txt
# - certificate_showcase-vibytes-tech.txt
# - rootca_showcase-vibytes-tech.txt
```

**Chạy setup script:**

```bash
./scripts/setup-ssl-showcase-only.sh
```

**Script sẽ:**
1. ✅ Verify certificates (issuer, subject, dates)
2. ✅ Verify private key matches certificate
3. ✅ Upload certificates lên VPS
4. ✅ Create fullchain certificate (domain cert + CA bundle)
5. ✅ Configure Nginx với HTTPS
6. ✅ Setup HTTP to HTTPS redirect
7. ✅ Set proper file permissions
8. ✅ Reload Nginx
9. ✅ Test SSL connection

**Output mẫu:**

```
================================================
SSL Setup - Showcase Domain Only
================================================

Validating local certificates...
✓ All certificates found

Verifying certificate...
  Issuer: CN=Sectigo RSA Domain Validation Secure Server CA
  Subject: CN=showcase.vibytes.tech
  notBefore=Nov 22 00:00:00 2025 GMT
  notAfter=Nov 22 23:59:59 2026 GMT

Verifying private key and certificate match...
✓ Private key and certificate match!

[... deployment process ...]

✅ SSL Setup Completed Successfully!

Your site is now secured with real SSL:
  🔒 https://showcase.vibytes.tech
```

#### 3.2 Setup SSL cho Auth Domain (Keycloak)

**Kiểm tra files:**

```bash
ls -la ca/auth/
# Phải có:
# - private_key_auth-vibytes-tech.txt
# - certificate_auth-vibytes-tech.txt
# - rootca_auth-vibytes-tech.txt
```

**Chạy setup script:**

```bash
./scripts/setup-ssl-auth.sh
```

**Script sẽ:**
1. ✅ Verify certificates
2. ✅ Upload lên VPS
3. ✅ Create fullchain certificate
4. ✅ Configure Nginx với HTTPS cho Keycloak
5. ✅ **Update Keycloak configuration** để dùng HTTPS:
   - Set `hostname=auth.vibytes.tech`
   - Set `proxy=edge` (Keycloak behind Nginx)
   - Set `hostname-strict=false`
6. ✅ Restart Keycloak service
7. ✅ Test SSL connection

**Output mẫu:**

```
================================================
SSL Setup - Auth Domain (Keycloak)
================================================

[... verification ...]

================================================
Updating Keycloak Configuration for HTTPS
================================================
Updating Keycloak configuration...
✓ Keycloak config updated
Restarting Keycloak...
✓ Keycloak restarted

✅ SSL Setup Completed Successfully!

Your Keycloak is now secured with real SSL:
  🔒 https://auth.vibytes.tech
  🔒 https://auth.vibytes.tech/admin/
```

---

### **Phase 4: Update Application Config**

#### 4.1 Update Environment Variables

**Update `.env.deploy`:**

```bash
nano .env.deploy
```

Thay đổi:

```bash
# Before (HTTP)
NEXT_PUBLIC_KEYCLOAK_URL=http://auth.vibytes.tech
NEXT_PUBLIC_APP_URL=http://showcase.vibytes.tech

# After (HTTPS)
NEXT_PUBLIC_KEYCLOAK_URL=https://auth.vibytes.tech
NEXT_PUBLIC_APP_URL=https://showcase.vibytes.tech
```

#### 4.2 Redeploy Application

```bash
./scripts/deploy-app-auto.sh
```

Script sẽ:
- Pull code mới
- Update `.env.local` trên VPS với HTTPS URLs
- Rebuild Next.js app
- Restart PM2

---

## 🔍 Verification & Testing

### Test 1: SSL Certificate

```bash
# Showcase
openssl s_client -connect showcase.vibytes.tech:443 -servername showcase.vibytes.tech < /dev/null 2>/dev/null | openssl x509 -noout -subject -dates

# Auth
openssl s_client -connect auth.vibytes.tech:443 -servername auth.vibytes.tech < /dev/null 2>/dev/null | openssl x509 -noout -subject -dates
```

**Expected:**
```
subject=CN = showcase.vibytes.tech
notBefore=Nov 22 00:00:00 2025 GMT
notAfter=Nov 22 23:59:59 2026 GMT
```

### Test 2: HTTPS Access

**Browser test:**
- https://showcase.vibytes.tech - Should show 🔒 lock icon
- https://auth.vibytes.tech - Should show 🔒 lock icon
- https://auth.vibytes.tech/admin/ - Keycloak admin console

### Test 3: HTTP Redirect

```bash
curl -I http://showcase.vibytes.tech
# Expected: HTTP 301 redirect to https://

curl -I http://auth.vibytes.tech
# Expected: HTTP 301 redirect to https://
```

### Test 4: SSL Labs Rating

Check SSL configuration quality:
- https://www.ssllabs.com/ssltest/analyze.html?d=showcase.vibytes.tech
- https://www.ssllabs.com/ssltest/analyze.html?d=auth.vibytes.tech

**Expected:** Grade A or A+

---

## 📊 SSL Certificate Files Explained

### 1. Private Key (`private_key_*.txt`)

- **Format:** RSA Private Key (PEM)
- **Purpose:** Decrypt SSL/TLS traffic
- **Security:** **NEVER share or commit to Git!**
- **Permissions:** 600 (read/write owner only)

**Example content:**
```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
[many lines of base64 encoded data]
-----END PRIVATE KEY-----
```

### 2. Domain Certificate (`certificate_*.txt`)

- **Format:** X.509 Certificate (PEM)
- **Purpose:** Proves domain ownership
- **Contains:** Domain name, validity dates, public key, issuer
- **Issued by:** Sectigo RSA Domain Validation Secure Server CA

**Example content:**
```
-----BEGIN CERTIFICATE-----
MIIGTzCCBTegAwIBAgIRANXZ7qF9n+...
[many lines of base64 encoded data]
-----END CERTIFICATE-----
```

### 3. CA Bundle (`rootca_*.txt`)

- **Format:** Multiple X.509 Certificates (PEM)
- **Purpose:** Chain of trust từ domain cert → root CA
- **Contains:** Intermediate CA + Root CA certificates
- **Used for:** Certificate validation

**Example content:**
```
-----BEGIN CERTIFICATE-----
[Intermediate CA Certificate]
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
[Root CA Certificate]
-----END CERTIFICATE-----
```

### 4. Fullchain Certificate (Created by script)

- **Format:** Combined PEM file
- **Purpose:** Complete certificate chain for Nginx
- **Created from:** `certificate_*.txt` + `rootca_*.txt`
- **Location on VPS:** `/etc/nginx/ssl/*-fullchain.crt`

**Creation:**
```bash
cat domain.crt > fullchain.crt
echo '' >> fullchain.crt
cat ca-bundle.crt >> fullchain.crt
```

---

## 🛠️ Troubleshooting

### Issue 1: Validation File Not Accessible (403/404)

**Symptoms:**
```bash
curl http://yourdomain/.well-known/pki-validation/[file].txt
# Returns: 403 Forbidden or 404 Not Found
```

**Solutions:**

1. **Check file exists:**
   ```bash
   ssh root@vps 'ls -la /var/www/*/public/.well-known/pki-validation/'
   ```

2. **Check permissions:**
   ```bash
   ssh root@vps 'sudo chown -R www-data:www-data /var/www/*/public/.well-known/'
   ssh root@vps 'sudo chmod -R 755 /var/www/*/public/.well-known/'
   ```

3. **Check Nginx config:**
   ```bash
   ssh root@vps 'sudo cat /etc/nginx/sites-available/showcase-app | grep -A5 .well-known'
   ```

4. **Check Nginx logs:**
   ```bash
   ssh root@vps 'sudo tail -50 /var/log/nginx/error.log'
   ```

5. **Disable conflicting configs:**
   ```bash
   # If you have multiple server blocks for same domain
   ssh root@vps 'sudo nginx -T | grep "server_name yourdomain"'
   ```

### Issue 2: SSL Certificate Mismatch

**Symptoms:**
```
SSL_CTX_use_PrivateKey(...) failed
(SSL: error:05800074:x509 certificate routines::key values mismatch)
```

**Solutions:**

1. **Verify key and cert match:**
   ```bash
   # Local check
   KEY_MD5=$(openssl rsa -in ca/auth/private_key_auth-vibytes-tech.txt -modulus -noout | openssl md5)
   CERT_MD5=$(openssl x509 -in ca/auth/certificate_auth-vibytes-tech.txt -modulus -noout | openssl md5)
   
   if [ "$KEY_MD5" = "$CERT_MD5" ]; then
       echo "✓ Match!"
   else
       echo "✗ Mismatch!"
   fi
   ```

2. **Re-download certificate từ Sectigo**

3. **Ensure using correct private key** (same key used for CSR)

### Issue 3: Fullchain Certificate Invalid

**Symptoms:**
```
cannot load certificate: PEM_read_bio_X509_AUX() failed
(SSL: error:0480006C:PEM routines::no start line)
```

**Solutions:**

1. **Check fullchain format:**
   ```bash
   ssh root@vps 'sudo head -5 /etc/nginx/ssl/auth-vibytes-tech-fullchain.crt'
   # Should start with: -----BEGIN CERTIFICATE-----
   ```

2. **Ensure newline between certificates:**
   ```bash
   # Correct format:
   -----END CERTIFICATE-----
   
   -----BEGIN CERTIFICATE-----  # ← blank line before this
   ```

3. **Recreate fullchain:**
   ```bash
   cat domain.crt > fullchain.crt
   echo '' >> fullchain.crt  # Add newline!
   cat ca-bundle.crt >> fullchain.crt
   ```

### Issue 4: Keycloak Not Working After SSL

**Symptoms:**
- Keycloak admin console not accessible
- Login redirects failing
- CORS errors in browser

**Solutions:**

1. **Check Keycloak config:**
   ```bash
   ssh root@vps 'sudo cat /opt/keycloak/conf/keycloak.conf | grep -E "(hostname|proxy)"'
   ```

   Should have:
   ```
   hostname=auth.vibytes.tech
   proxy=edge
   hostname-strict=false
   ```

2. **Restart Keycloak:**
   ```bash
   ssh root@vps 'sudo systemctl restart keycloak'
   ```

3. **Check Keycloak logs:**
   ```bash
   ssh root@vps 'sudo journalctl -u keycloak -n 100 --no-pager'
   ```

4. **Update app environment** to use HTTPS Keycloak URL

### Issue 5: Mixed Content Warnings

**Symptoms:**
- Browser console shows: "Mixed Content: The page at 'https://...' was loaded over HTTPS, but requested an insecure resource 'http://...'"

**Solutions:**

1. **Update all URLs to HTTPS** in `.env.deploy`:
   ```bash
   NEXT_PUBLIC_KEYCLOAK_URL=https://auth.vibytes.tech
   NEXT_PUBLIC_APP_URL=https://showcase.vibytes.tech
   ```

2. **Redeploy app:**
   ```bash
   ./scripts/deploy-app-auto.sh
   ```

3. **Check for hardcoded HTTP URLs** in code

---

## 📝 Scripts Reference

### Validation Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `deploy-validation.sh` | Deploy validation file for showcase | `./scripts/deploy-validation.sh` |
| `deploy-validation-auth.sh` | Deploy validation file for auth | `./scripts/deploy-validation-auth.sh` |
| `fix-validation-nginx.sh` | Fix Nginx conflicts for validation | `./scripts/fix-validation-nginx.sh` |

### SSL Setup Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup-ssl-showcase-only.sh` | Setup SSL for showcase | `./scripts/setup-ssl-showcase-only.sh` |
| `setup-ssl-auth.sh` | Setup SSL for auth (Keycloak) | `./scripts/setup-ssl-auth.sh` |

---

## 🔐 Security Best Practices

### 1. File Permissions

**On VPS:**
```bash
# Private keys: Only readable by root
sudo chmod 600 /etc/nginx/ssl/*.key
sudo chown root:root /etc/nginx/ssl/*.key

# Certificates: Readable by all (but writable only by root)
sudo chmod 644 /etc/nginx/ssl/*.crt
sudo chown root:root /etc/nginx/ssl/*.crt
```

### 2. Never Commit Certificates to Git

**`.gitignore` already includes:**
```gitignore
# SSL certificates
ca/**/*.txt
ca/**/*.key
ca/**/*.crt
ca/**/*.pem
ca/**/*.csr
```

### 3. Use Strong SSL Configuration

**Nginx SSL config** (already in scripts):
```nginx
# Modern SSL protocols only
ssl_protocols TLSv1.2 TLSv1.3;

# Strong ciphers
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:...';
ssl_prefer_server_ciphers off;

# HSTS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
```

### 4. Certificate Renewal

Sectigo certificates usually valid for **1 year**. Setup reminder:

```bash
# Create cron job to remind 30 days before expiry
# Check certificate expiry:
openssl x509 -in ca/showcase/certificate_showcase-vibytes-tech.txt -noout -enddate
```

### 5. Backup Certificates

```bash
# Backup to secure location
tar -czf ssl-certificates-backup-$(date +%Y%m%d).tar.gz ca/
# Store in encrypted cloud storage or password manager
```

---

## 📋 Checklist

### Before Starting

- [ ] Đã mua SSL certificates từ Sectigo
- [ ] Có đủ 3 files cho mỗi domain:
  - [ ] Private key
  - [ ] Domain certificate
  - [ ] CA bundle
- [ ] Files đã được lưu vào đúng thư mục `ca/`

### Domain Validation

- [ ] Deploy validation file lên VPS
- [ ] File accessible từ internet (HTTP 200)
- [ ] Click "Validate" trên Sectigo
- [ ] Chờ validation complete (5-30 phút)
- [ ] Download domain certificate

### SSL Setup - Showcase

- [ ] Có đủ 3 files trong `ca/showcase/`
- [ ] Run `./scripts/setup-ssl-showcase-only.sh`
- [ ] Test: `https://showcase.vibytes.tech` shows lock icon
- [ ] Test: `http://showcase.vibytes.tech` redirects to HTTPS

### SSL Setup - Auth (Keycloak)

- [ ] Có đủ 3 files trong `ca/auth/`
- [ ] Run `./scripts/setup-ssl-auth.sh`
- [ ] Keycloak restarted successfully
- [ ] Test: `https://auth.vibytes.tech` shows lock icon
- [ ] Test: `https://auth.vibytes.tech/admin/` accessible

### Application Update

- [ ] Update `.env.deploy` với HTTPS URLs
- [ ] Run `./scripts/deploy-app-auto.sh`
- [ ] App sử dụng HTTPS Keycloak URL
- [ ] No mixed content warnings in browser
- [ ] Login/logout works correctly

### Final Verification

- [ ] Both domains show SSL lock icon
- [ ] SSL Labs grade A or A+
- [ ] No certificate warnings
- [ ] HTTP auto-redirects to HTTPS
- [ ] Keycloak authentication works
- [ ] Application fully functional

---

## 📚 Related Documentation

- [VPS Deployment Guide](./04-VPS_DEPLOYMENT_GUIDE.md)
- [Keycloak Setup](./05-KEYCLOAK_SETUP.md)
- [Troubleshooting Guide](./12-TROUBLESHOOTING.md)
- [Scripts README](../scripts/README.md)

---

**Last Updated**: November 22, 2025  
**Applies to**: Project v2.0.0+  
**SSL Provider**: Sectigo (adaptable for other providers)

