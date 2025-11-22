# Hướng dẫn thiết lập SSL cho Keycloak

> **Tài liệu này hướng dẫn cách thiết lập HTTPS cho Keycloak (auth.vibytes.tech) sử dụng SSL certificate của bạn.**

## 📋 Tổng quan

Script `setup-ssl-keycloak.sh` tự động hóa toàn bộ quá trình cài đặt SSL cho Keycloak, bao gồm:
- Upload certificates lên VPS
- Cấu hình Nginx với SSL
- Cập nhật Keycloak để hoạt động với HTTPS
- Cấu hình security headers và SSL best practices

## 🔑 Yêu cầu trước khi bắt đầu

1. **SSL Certificates** (trong thư mục `ca/auth/`):
   - `private_key_auth-vibytes-tech.txt` - Private key ✅
   - `rootca_auth-vibytes-tech.txt` - Root CA certificate ✅
   - `certificate_auth-vibytes-tech.txt` (optional) - Domain certificate
   
   > **Note:** Script hỗ trợ nhiều naming patterns. Xem [ca/README.md](../ca/README.md) để biết thêm.

2. **VPS đã cài đặt**:
   - Nginx
   - Keycloak
   - PostgreSQL

3. **File cấu hình**:
   - `.env` đã được cấu hình đúng

## 🚀 Cách sử dụng

### Bước 1: Kiểm tra certificates

```bash
# Kiểm tra các file certificate có tồn tại
ls -la ca/auth/

# Kết quả mong đợi:
# -rw-r--r--  private_key_auth-vibytes-tech.txt
# -rw-r--r--  rootca_auth-vibytes-tech.txt
# -rw-r--r--  certificate_auth-vibytes-tech.txt (optional)
```

Nếu chưa có, copy certificates vào:
```bash
cp your-private-key.txt ca/auth/private_key_auth-vibytes-tech.txt
cp your-rootca.txt ca/auth/rootca_auth-vibytes-tech.txt
```

### Bước 2: Chạy script setup

```bash
# Từ thư mục gốc của project
./scripts/setup-ssl-keycloak.sh
```

### Bước 3: Đợi script hoàn thành

Script sẽ thực hiện các bước sau:

1. ✅ **Upload certificates** → VPS `/etc/nginx/ssl/`
2. ✅ **Configure Nginx** → HTTPS với security headers
3. ✅ **Update Keycloak** → Rebuild với HTTPS support
4. ✅ **Test connection** → Verify SSL hoạt động

Quá trình mất khoảng **2-3 phút**.

### Bước 4: Verify SSL

Sau khi hoàn thành, truy cập:

```
https://auth.vibytes.tech
https://auth.vibytes.tech/admin
```

## 📊 Chi tiết quá trình

### 1. Upload Certificates

```
Local (ca/auth/)                        VPS (/etc/nginx/ssl/)
├── private_key_auth-*.txt        →     ├── vibytes-tech.key (600)
├── rootca_auth-*.txt            →     ├── vibytes-tech-ca.crt (644)
└── certificate_auth-*.txt       →     ├── vibytes-tech.crt (644)
                                        └── vibytes-tech-fullchain.crt (644)
```

### 2. Nginx Configuration

Script tạo cấu hình Nginx với:

**Security Features:**
- ✅ TLS 1.2 & 1.3
- ✅ Strong cipher suites
- ✅ OCSP stapling
- ✅ HSTS headers
- ✅ HTTP → HTTPS redirect

**Example config:**
```nginx
server {
    listen 443 ssl http2;
    server_name auth.vibytes.tech;

    ssl_certificate /etc/nginx/ssl/vibytes-tech-fullchain.crt;
    ssl_certificate_key /etc/nginx/ssl/vibytes-tech.key;
    
    # SSL protocols & ciphers
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:...';
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000";
    
    # Proxy to Keycloak
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header X-Forwarded-Proto https;
        ...
    }
}
```

### 3. Keycloak Configuration

Update `/opt/keycloak/conf/keycloak.conf`:

```conf
# HTTP/HTTPS
http-enabled=true
http-port=8080
hostname=auth.vibytes.tech
hostname-strict=false

# Proxy settings for HTTPS
proxy-headers=xforwarded
proxy=edge
```

## 🔍 Kiểm tra & Troubleshooting

### Test SSL từ local machine

```bash
# Test HTTPS connection
curl -I https://auth.vibytes.tech

# Detailed SSL info
openssl s_client -connect auth.vibytes.tech:443 -servername auth.vibytes.tech

# Check certificate expiry
echo | openssl s_client -connect auth.vibytes.tech:443 2>/dev/null | \
  openssl x509 -noout -dates
```

### Check trên VPS

```bash
# SSH vào VPS
ssh root@103.82.20.169

# Check Nginx
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/keycloak-error.log

# Check certificates
sudo ls -la /etc/nginx/ssl/
openssl x509 -in /etc/nginx/ssl/vibytes-tech-fullchain.crt -text -noout

# Check Keycloak
sudo systemctl status keycloak
sudo journalctl -u keycloak -f

# Test from VPS
curl -I https://auth.vibytes.tech
```

### Common Issues

#### ❌ Issue 1: Certificate not found

**Symptom:**
```
✗ Error: Private key not found in ca/auth/
```

**Solution:**
```bash
# Kiểm tra files trong thư mục ca/auth/
ls -la ca/auth/

# Đảm bảo files ở đúng vị trí và đúng tên
# Script chấp nhận các tên sau:
# - private_key_auth-vibytes-tech.txt (recommended)
# - private_key_vibytes-tech.txt
# - private_key.txt

# Di chuyển file nếu cần
mv your-private-key.txt ca/auth/private_key_auth-vibytes-tech.txt
mv your-rootca.txt ca/auth/rootca_auth-vibytes-tech.txt
```

#### ❌ Issue 2: Nginx configuration test failed

**Symptom:**
```
nginx: [emerg] cannot load certificate
```

**Solution:**
```bash
# SSH vào VPS
ssh root@103.82.20.169

# Check certificate files
sudo ls -la /etc/nginx/ssl/

# Verify certificate
sudo openssl x509 -in /etc/nginx/ssl/vibytes-tech-fullchain.crt -text -noout

# Restore backup if needed
sudo cp /etc/nginx/sites-available/keycloak.backup /etc/nginx/sites-available/keycloak
sudo systemctl reload nginx
```

#### ❌ Issue 3: Keycloak không start

**Symptom:**
```
keycloak.service: Failed with result 'exit-code'
```

**Solution:**
```bash
# Check logs
sudo journalctl -u keycloak -n 100

# Common issues:
# - Database connection
# - Config syntax error

# Restore config
sudo cp /opt/keycloak/conf/keycloak.conf.backup /opt/keycloak/conf/keycloak.conf

# Restart
sudo systemctl restart keycloak
```

#### ❌ Issue 4: SSL certificate mismatch

**Symptom:**
```
SSL: error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure
```

**Solution:**
```bash
# Verify certificate matches domain
openssl x509 -in ca/auth/rootca_auth-vibytes-tech.txt -text -noout | grep -A1 "Subject:"

# Check if certificate is for vibytes.tech or *.vibytes.tech
# If wildcard, it should work for auth.vibytes.tech

# Check Subject Alternative Names
openssl x509 -in ca/auth/rootca_auth-vibytes-tech.txt -text -noout | grep -A1 "Subject Alternative Name"
```

## 🔐 Security Best Practices

### Certificate Management

✅ **DO:**
- Backup private key ở nơi an toàn offline
- Monitor certificate expiration date
- Use strong permissions (600 for private key)
- Keep certificates in encrypted storage

❌ **DON'T:**
- Commit private key to Git (đã config .gitignore)
- Share private key qua email/chat
- Reuse same certificate cho nhiều domains (nếu không phải wildcard)
- Ignore certificate expiration warnings

### Monitoring

Set up certificate expiration monitoring:

```bash
# Add to crontab trên VPS
0 0 * * * /usr/bin/openssl x509 -enddate -noout -in /etc/nginx/ssl/vibytes-tech-fullchain.crt | \
  mail -s "SSL Certificate Check" your-email@example.com
```

## 📝 Certificate Renewal

Khi certificate hết hạn (thường 1 năm):

### Bước 1: Lấy certificate mới

Liên hệ nhà cung cấp SSL để gia hạn và nhận:
- New private key (hoặc reuse existing)
- New certificate
- New CA bundle

### Bước 2: Thay thế files

```bash
# Backup old certificates
cp -r ca/auth ca/auth.backup-$(date +%Y%m%d)

# Copy new certificates
cp /path/to/new-private-key.txt ca/auth/private_key_auth-vibytes-tech.txt
cp /path/to/new-rootca.txt ca/auth/rootca_auth-vibytes-tech.txt
cp /path/to/new-certificate.txt ca/auth/certificate_auth-vibytes-tech.txt

# Verify new certificates
openssl x509 -in ca/auth/rootca_auth-vibytes-tech.txt -text -noout | grep -A2 "Validity"
```

### Bước 3: Re-run setup script

```bash
./scripts/setup-ssl-keycloak.sh
```

Script sẽ tự động:
- Upload certificates mới
- Update Nginx config
- Restart services
- Test SSL

## 🔗 Related Documentation

- [05-KEYCLOAK_SETUP.md](./05-KEYCLOAK_SETUP.md) - Keycloak installation
- [09-DEPLOYMENT.md](./09-DEPLOYMENT.md) - Full deployment guide
- [04-VPS_DEPLOYMENT_GUIDE.md](./04-VPS_DEPLOYMENT_GUIDE.md) - VPS setup

## 📞 Support

Nếu gặp vấn đề:

1. **Check logs:**
   ```bash
   sudo journalctl -u nginx -f
   sudo journalctl -u keycloak -f
   ```

2. **Verify DNS:**
   ```bash
   nslookup auth.vibytes.tech
   dig auth.vibytes.tech
   ```

3. **Test from external:**
   ```bash
   # Test SSL
   https://www.ssllabs.com/ssltest/analyze.html?d=auth.vibytes.tech
   
   # Or use curl
   curl -vI https://auth.vibytes.tech
   ```

## 🎯 Summary

Script này giúp bạn:
- ✅ Tự động upload và configure SSL certificates
- ✅ Setup HTTPS cho Keycloak với best practices
- ✅ Configure security headers và SSL settings
- ✅ Test và verify SSL connection

**Thời gian:** ~2-3 phút  
**Độ khó:** Dễ (fully automated)  
**Yêu cầu:** Có SSL certificates hợp lệ

---

**Last Updated:** November 22, 2024  
**Version:** 1.0

