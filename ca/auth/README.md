# SSL Certificates cho auth.vibytes.tech

> **Thư mục này chứa SSL certificates cho Keycloak authentication server**

## 📁 Cấu trúc file

Thư mục này cần chứa các file sau:

### Required Files (Bắt buộc)

1. **Private Key** - Một trong các tên sau:
   - `private_key_auth-vibytes-tech.txt` ✅ (recommended)
   - `private_key_vibytes-tech.txt`
   - `private_key.txt`

2. **Root CA Certificate** - Một trong các tên sau:
   - `rootca_auth-vibytes-tech.txt` ✅ (recommended)
   - `rootca_vibytes-tech.txt`
   - `rootca.txt`

### Optional Files

3. **Domain Certificate** (optional):
   - `certificate_auth-vibytes-tech.txt` ✅ (recommended)
   - `certificate_vibytes-tech.txt`
   - `certificate.txt`

> 💡 **Note:** Nếu không có domain certificate, script sẽ tự động sử dụng Root CA certificate.

## 🔍 Kiểm tra certificates

### Kiểm tra Private Key

```bash
# View key info
openssl rsa -in private_key_auth-vibytes-tech.txt -text -noout

# Check if key is valid
openssl rsa -in private_key_auth-vibytes-tech.txt -check

# Get key modulus (để compare với certificate)
openssl rsa -in private_key_auth-vibytes-tech.txt -modulus -noout | openssl md5
```

### Kiểm tra Certificate

```bash
# View certificate details
openssl x509 -in rootca_auth-vibytes-tech.txt -text -noout

# Check expiration date
openssl x509 -in rootca_auth-vibytes-tech.txt -noout -dates

# Get certificate modulus
openssl x509 -in rootca_auth-vibytes-tech.txt -modulus -noout | openssl md5

# Verify certificate and key match
# (Modulus của key và cert phải giống nhau)
```

### Verify Domain

```bash
# Check what domain(s) the certificate is for
openssl x509 -in rootca_auth-vibytes-tech.txt -text -noout | grep -A1 "Subject:"

# Check Subject Alternative Names (SAN)
openssl x509 -in rootca_auth-vibytes-tech.txt -text -noout | grep -A1 "Subject Alternative Name"
```

## 🚀 Sử dụng

Sau khi đã có đầy đủ certificates trong thư mục này, chạy script setup:

```bash
# Từ thư mục gốc của project
./scripts/setup-ssl-keycloak.sh
```

Script sẽ:
1. Tự động detect files trong `ca/auth/`
2. Upload lên VPS tại `/etc/nginx/ssl/`
3. Configure Nginx với HTTPS
4. Update Keycloak configuration
5. Test SSL connection

## 🔐 Security

### Permissions

Các file trong thư mục này **KHÔNG** được commit lên Git:

```bash
# Check git status
git status ca/auth/

# Kết quả mong đợi: No changes (files are ignored)
```

### Backup

**⚠️ QUAN TRỌNG:** Backup private key ở nơi an toàn!

```bash
# Backup locally (encrypted)
tar czf ~/ssl-backup-$(date +%Y%m%d).tar.gz ca/auth/*.txt
gpg -c ~/ssl-backup-*.tar.gz  # Encrypt with password
rm ~/ssl-backup-*.tar.gz      # Remove unencrypted

# Hoặc backup to secure cloud storage
```

### Best Practices

✅ **DO:**
- Giữ private key ở chế độ bảo mật cao
- Backup certificates encrypted
- Monitor expiration dates
- Use strong file permissions trên VPS (600 for key, 644 for certs)

❌ **DON'T:**
- Share private key qua email/chat/Slack
- Commit private key to Git
- Reuse certificates giữa các environments (dev/staging/prod)
- Ignore certificate warnings

## 📊 Certificate Info

Sau khi deploy, certificates sẽ được đặt tại VPS:

```
/etc/nginx/ssl/
├── vibytes-tech.key              # Private key (600)
├── vibytes-tech-ca.crt           # Root CA (644)
├── vibytes-tech.crt              # Domain cert (644) - if provided
└── vibytes-tech-fullchain.crt    # Full chain: domain + CA (644)
```

## 🔄 Certificate Renewal

### Khi nào cần renew?

```bash
# Check expiration
openssl x509 -in rootca_auth-vibytes-tech.txt -noout -enddate

# Set reminder 30 days trước khi hết hạn
```

### Renewal Steps

1. **Lấy certificates mới** từ SSL provider
2. **Backup certificates cũ:**
   ```bash
   mv ca/auth ca/auth.old-$(date +%Y%m%d)
   mkdir ca/auth
   ```
3. **Copy certificates mới** vào `ca/auth/`
4. **Verify certificates:**
   ```bash
   openssl x509 -in ca/auth/rootca_auth-vibytes-tech.txt -text -noout
   ```
5. **Re-run setup script:**
   ```bash
   ./scripts/setup-ssl-keycloak.sh
   ```
6. **Test:**
   ```bash
   curl -I https://auth.vibytes.tech
   ```

## 📝 Troubleshooting

### Error: Certificate and key don't match

```bash
# Compare modulus - should be identical
openssl rsa -in private_key_auth-vibytes-tech.txt -modulus -noout | openssl md5
openssl x509 -in rootca_auth-vibytes-tech.txt -modulus -noout | openssl md5
```

### Error: Certificate has expired

```bash
# Check dates
openssl x509 -in rootca_auth-vibytes-tech.txt -noout -dates

# Solution: Get new certificate from provider
```

### Error: Wrong domain in certificate

```bash
# Check certificate domain
openssl x509 -in rootca_auth-vibytes-tech.txt -text -noout | grep DNS

# Certificate must be for:
# - auth.vibytes.tech (specific subdomain)
# - *.vibytes.tech (wildcard for all subdomains)
# - vibytes.tech (root + all subdomains)
```

## 📞 Support

Nếu gặp vấn đề với certificates:

1. **Verify files:**
   ```bash
   ls -lh ca/auth/
   file ca/auth/*.txt
   ```

2. **Check certificate validity:**
   ```bash
   openssl x509 -in ca/auth/rootca_auth-vibytes-tech.txt -text -noout
   ```

3. **Test script (dry-run):**
   ```bash
   # Script sẽ validate certificates trước khi upload
   ./scripts/setup-ssl-keycloak.sh
   ```

## 🔗 Related Documentation

- [Setup SSL Script Usage](../../docs/12-SSL_KEYCLOAK_SETUP.md)
- [Keycloak Setup Guide](../../docs/05-KEYCLOAK_SETUP.md)
- [VPS Deployment](../../docs/04-VPS_DEPLOYMENT_GUIDE.md)

---

**Domain:** auth.vibytes.tech  
**SSL Provider:** [Your SSL Provider]  
**Certificate Type:** [Type, e.g., DV SSL, Wildcard, etc.]  
**Valid Until:** [Check with openssl command above]

